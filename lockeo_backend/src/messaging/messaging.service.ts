import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Conversation } from '../entities/conversation.entity';
import { Message } from '../entities/message.entity';
import { User } from '../entities/user.entity';

export interface MessagePayload {
  message_id: number;
  conversation_id: number;
  sender_user_id: number;
  text: string;
  status: string;
  created_at: string;
  read_at: string | null;
}

export interface ConversationListItemPayload {
  conversation_id: number;
  created_at: string;
  other_user: {
    user_id: number;
    login: string | null;
    first_name: string | null;
    last_name: string | null;
  } | null;
  last_message: {
    message_id: number;
    sender_user_id: number;
    text: string;
    created_at: string;
  } | null;
  unread_count: number;
}

export interface EnsureConversationPayload {
  conversation_id: number;
  is_created: boolean;
}

@Injectable()
export class MessagingService {
  constructor(
    @InjectRepository(Conversation)
    private readonly conversationRepo: Repository<Conversation>,
    @InjectRepository(Message)
    private readonly messageRepo: Repository<Message>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  private async getConversationOrThrow(
    conversationId: number,
  ): Promise<Conversation> {
    const conversation = await this.conversationRepo.findOne({
      where: { conversation_id: conversationId },
      relations: ['renter', 'owner'],
    });

    if (!conversation) {
      throw new NotFoundException('Conversation introuvable');
    }

    return conversation;
  }

  async assertConversationMembership(
    conversationId: number,
    userId: number,
  ): Promise<void> {
    const conversation = await this.getConversationOrThrow(conversationId);
    const isRenter = conversation.renter?.user_id === userId;
    const isOwner = conversation.owner?.user_id === userId;

    if (!isRenter && !isOwner) {
      throw new ForbiddenException('Accès refusé à cette conversation');
    }
  }

  async listMessages(
    conversationId: number,
    userId: number,
  ): Promise<MessagePayload[]> {
    await this.assertConversationMembership(conversationId, userId);

    const messages = await this.messageRepo.find({
      where: { conversation: { conversation_id: conversationId } },
      relations: ['sender', 'conversation'],
      order: { created_at: 'ASC', message_id: 'ASC' },
    });

    return messages.map((m) => this.toPayload(m));
  }

  async listConversationsForUser(
    userId: number,
  ): Promise<ConversationListItemPayload[]> {
    const conversations = await this.conversationRepo.find({
      where: [{ renter: { user_id: userId } }, { owner: { user_id: userId } }],
      relations: ['renter', 'owner'],
      order: { created_at: 'DESC' },
    });

    const rows = await Promise.all(
      conversations.map(async (conversation) => {
        const otherUser =
          conversation.renter?.user_id === userId
            ? conversation.owner
            : conversation.renter;

        const lastMessage = await this.messageRepo.findOne({
          where: {
            conversation: { conversation_id: conversation.conversation_id },
          },
          relations: ['sender'],
          order: { created_at: 'DESC', message_id: 'DESC' },
        });

        return {
          conversation_id: conversation.conversation_id,
          created_at: conversation.created_at.toISOString(),
          other_user: otherUser
            ? {
                user_id: otherUser.user_id,
                login: otherUser.login,
                first_name: otherUser.first_name ?? null,
                last_name: otherUser.last_name ?? null,
              }
            : null,
          last_message: lastMessage
            ? {
                message_id: lastMessage.message_id,
                sender_user_id: lastMessage.sender.user_id,
                text: lastMessage.content,
                created_at: lastMessage.created_at.toISOString(),
              }
            : null,
          unread_count: 0,
        } satisfies ConversationListItemPayload;
      }),
    );

    rows.sort((a, b) => {
      const aTime = a.last_message?.created_at ?? a.created_at;
      const bTime = b.last_message?.created_at ?? b.created_at;
      return bTime.localeCompare(aTime);
    });

    return rows;
  }

  async ensureConversationBetweenUsers(
    currentUserId: number,
    otherUserId: number,
  ): Promise<EnsureConversationPayload> {
    if (currentUserId === otherUserId) {
      throw new BadRequestException(
        'Impossible de créer une conversation avec soi-même',
      );
    }

    const [currentUser, otherUser] = await Promise.all([
      this.userRepo.findOne({ where: { user_id: currentUserId } }),
      this.userRepo.findOne({ where: { user_id: otherUserId } }),
    ]);

    if (!currentUser) {
      throw new NotFoundException('Utilisateur courant introuvable');
    }

    if (!otherUser) {
      throw new NotFoundException('Utilisateur cible introuvable');
    }

    const existing = await this.conversationRepo.findOne({
      where: [
        { renter: { user_id: currentUserId }, owner: { user_id: otherUserId } },
        { renter: { user_id: otherUserId }, owner: { user_id: currentUserId } },
      ],
      relations: ['renter', 'owner'],
      order: { conversation_id: 'DESC' },
    });

    if (existing) {
      return {
        conversation_id: existing.conversation_id,
        is_created: false,
      };
    }

    const created = await this.conversationRepo.save(
      this.conversationRepo.create({
        renter: currentUser,
        owner: otherUser,
      }),
    );

    return {
      conversation_id: created.conversation_id,
      is_created: true,
    };
  }

  async sendMessage(
    conversationId: number,
    senderUserId: number,
    text: string,
  ): Promise<MessagePayload> {
    await this.assertConversationMembership(conversationId, senderUserId);

    const [conversation, sender] = await Promise.all([
      this.conversationRepo.findOne({
        where: { conversation_id: conversationId },
      }),
      this.userRepo.findOne({ where: { user_id: senderUserId } }),
    ]);

    if (!conversation) {
      throw new NotFoundException('Conversation introuvable');
    }

    if (!sender) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    const saved = await this.messageRepo.save(
      this.messageRepo.create({
        content: text.trim(),
        conversation,
        sender,
      }),
    );

    const hydrated = await this.messageRepo.findOne({
      where: { message_id: saved.message_id },
      relations: ['sender', 'conversation'],
    });

    if (!hydrated) {
      throw new NotFoundException('Message introuvable après création');
    }

    return this.toPayload(hydrated);
  }

  private toPayload(message: Message): MessagePayload {
    return {
      message_id: message.message_id,
      conversation_id: message.conversation.conversation_id,
      sender_user_id: message.sender.user_id,
      text: message.content,
      status: 'sent',
      created_at: message.created_at.toISOString(),
      read_at: null,
    };
  }
}
