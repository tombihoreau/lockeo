import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { MessagingService } from './messaging.service';
import { EnsureConversationDto } from './dto/ensure-conversation.dto';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('conversations')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
@Controller('conversations')
export class MessagingController {
  constructor(private readonly messagingService: MessagingService) {}

  @Post('ensure')
  @ApiOperation({
    summary: 'Trouver ou créer une conversation entre 2 utilisateurs',
  })
  async ensureConversation(
    @Req() req: RequestWithUser,
    @Body() body: EnsureConversationDto,
  ) {
    return this.messagingService.ensureConversationBetweenUsers(
      req.user.userId,
      body.otherUserId,
    );
  }

  @Get()
  @ApiOperation({
    summary: "Lister les conversations de l'utilisateur connecté",
  })
  async listConversations(@Req() req: RequestWithUser) {
    return this.messagingService.listConversationsForUser(req.user.userId);
  }

  @Get(':conversationId/messages')
  @ApiOperation({ summary: "Lister les messages d'une conversation" })
  async listMessages(
    @Req() req: RequestWithUser,
    @Param('conversationId', ParseIntPipe) conversationId: number,
  ) {
    return this.messagingService.listMessages(conversationId, req.user.userId);
  }

  @Post(':conversationId/read')
  @ApiOperation({ summary: "Marquer les messages d'une conversation comme lus" })
  async markConversationRead(
    @Req() req: RequestWithUser,
    @Param('conversationId', ParseIntPipe) conversationId: number,
  ) {
    await this.messagingService.markConversationAsRead(
      conversationId,
      req.user.userId,
    );
    return { success: true };
  }
}
