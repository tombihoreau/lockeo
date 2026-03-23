import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { NotificationsService } from './notifications.service';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('notifications')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Get()
  @ApiOperation({ summary: "Lister les notifications de l'utilisateur connecté" })
  @ApiOkResponse({ description: 'Notifications utilisateur' })
  listMine(@Req() req: RequestWithUser) {
    return this.notificationsService.listForUser(req.user.userId);
  }
}
