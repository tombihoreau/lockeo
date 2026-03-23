import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserNotification } from '../entities/user-notification.entity';

export interface NotificationListItemPayload {
  user_notification_id: number;
  destination_user_id: number;
  template_id: number | null;
  status: string;
  created_at: string;
  payload: Record<string, unknown>;
  template: {
    template_id: number;
    code: string;
    title: string;
    content: string;
  } | null;
}

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(UserNotification)
    private readonly userNotificationRepo: Repository<UserNotification>,
  ) {}

  async listForUser(userId: number): Promise<NotificationListItemPayload[]> {
    const rows = await this.userNotificationRepo.find({
      where: { destinationUser: { user_id: userId } },
      relations: ['template', 'destinationUser'],
      order: { created_at: 'DESC', user_notification_id: 'DESC' },
    });

    return rows.map((row) => ({
      user_notification_id: row.user_notification_id,
      destination_user_id: row.destinationUser.user_id,
      template_id: row.template?.template_id ?? null,
      status: row.status,
      created_at: row.created_at.toISOString(),
      payload:
        row.conversation_id == null
          ? {}
          : { conversation_id: row.conversation_id },
      template:
        row.template == null
          ? null
          : {
              template_id: row.template.template_id,
              code: row.template.code,
              title: row.template.title,
              content: row.template.content,
            },
    }));
  }
}
