import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { NotificationTemplate } from './notification-template.entity';
import { User } from './user.entity';

@Entity('user_notifications')
export class UserNotification {
  @PrimaryGeneratedColumn()
  user_notification_id: number;

  @ManyToOne(() => NotificationTemplate, (t) => t.userNotifications, {
    onDelete: 'SET NULL',
    nullable: true,
  })
  template: NotificationTemplate;

  @ManyToOne(() => User, (u) => u.notifications, { onDelete: 'CASCADE' })
  destinationUser: User;

  @Column({ length: 50 })
  status: string;

  @Column({ type: 'int', nullable: true })
  conversation_id: number | null;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;
}
