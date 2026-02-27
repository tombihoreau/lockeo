import { Controller, Get, Param, ParseIntPipe, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { MessagingService } from './messaging.service';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('conversations')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
@Controller('conversations')
export class MessagingController {
  constructor(private readonly messagingService: MessagingService) {}

  @Get()
  @ApiOperation({ summary: "Lister les conversations de l'utilisateur connecté" })
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
}
