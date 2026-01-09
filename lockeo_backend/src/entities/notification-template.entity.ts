import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { UserNotification } from './user-notification.entity';

@Entity('notification_templates')
export class NotificationTemplate {
  @PrimaryGeneratedColumn()
  template_id: number;

  @Column({ length: 50, unique: true })
  code: string;

  @Column({ length: 250 })
  title: string;

  @Column({ type: 'text' })
  content: string;

  @OneToMany(() => UserNotification, (un) => un.template)
  userNotifications: UserNotification[];
}
