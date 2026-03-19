import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Logger, UsePipes, ValidationPipe } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { MessagingService } from './messaging.service';
import { JoinConversationDto } from './dto/join-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { TypingDto } from './dto/typing.dto';

type AuthPayload = {
  sub?: number;
};

type SocketAuth = {
  token?: unknown;
};

type SocketHandshake = {
  auth?: SocketAuth;
  headers: {
    authorization?: string | string[];
  };
};

@WebSocketGateway({
  cors: { origin: '*' },
})
@UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
export class MessagingGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(MessagingGateway.name);

  constructor(
    private readonly messagingService: MessagingService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  handleConnection(client: Socket): void {
    try {
      this.getUserIdFromClient(client);
      this.logger.log(`Socket connecté: ${client.id}`);
    } catch {
      client.emit('chat:error', { message: 'Unauthorized' });
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket): void {
    this.logger.log(`Socket déconnecté: ${client.id}`);
  }

  @SubscribeMessage('conversation:join')
  async joinConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() body: JoinConversationDto,
  ): Promise<void> {
    const userId = this.getUserIdFromClient(client);
    await this.messagingService.assertConversationMembership(
      body.conversationId,
      userId,
    );

    const room = this.roomFor(body.conversationId);
    await client.join(room);

    const history = await this.messagingService.listMessages(
      body.conversationId,
      userId,
    );
    client.emit('conversation:history', {
      conversationId: body.conversationId,
      messages: history,
    });
  }

  @SubscribeMessage('conversation:leave')
  async leaveConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() body: JoinConversationDto,
  ): Promise<void> {
    const room = this.roomFor(body.conversationId);
    await client.leave(room);
  }

  @SubscribeMessage('conversation:send')
  async sendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() body: SendMessageDto,
  ): Promise<void> {
    const userId = this.getUserIdFromClient(client);
    const text = body.text.trim();
    if (!text) {
      client.emit('chat:error', {
        message: 'Le message ne peut pas être vide',
      });
      return;
    }

    const message = await this.messagingService.sendMessage(
      body.conversationId,
      userId,
      text,
    );
    const room = this.roomFor(body.conversationId);

    this.server.to(room).emit('conversation:new_message', {
      conversationId: body.conversationId,
      message,
    });
  }

  @SubscribeMessage('conversation:typing')
  async typing(
    @ConnectedSocket() client: Socket,
    @MessageBody() body: TypingDto,
  ): Promise<void> {
    const userId = this.getUserIdFromClient(client);
    await this.messagingService.assertConversationMembership(
      body.conversationId,
      userId,
    );

    const room = this.roomFor(body.conversationId);
    client.to(room).emit('conversation:typing', {
      conversationId: body.conversationId,
      senderUserId: userId,
      isTyping: body.isTyping,
    });
  }

  private roomFor(conversationId: number): string {
    return `conversation:${conversationId}`;
  }

  private getUserIdFromClient(client: Socket): number {
    const token = this.extractBearerToken(client);
    const secret = this.configService.get<string>('JWT_SECRET', 'dev-secret');
    const payload = this.jwtService.verify<AuthPayload>(token, { secret });

    if (!payload?.sub || typeof payload.sub !== 'number') {
      throw new Error('Unauthorized');
    }

    return payload.sub;
  }

  private extractBearerToken(client: Socket): string {
    const handshake = client.handshake as SocketHandshake;
    const authToken = handshake.auth?.token;
    if (typeof authToken === 'string' && authToken.trim().length > 0) {
      return authToken.trim();
    }

    const rawHeader = handshake.headers.authorization;
    if (typeof rawHeader === 'string' && rawHeader.startsWith('Bearer ')) {
      return rawHeader.slice(7).trim();
    }

    throw new Error('Unauthorized');
  }
}
