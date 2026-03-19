import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { User } from './user.entity';

@Entity('notification_preferences')
export class NotificationPreference {
  @PrimaryGeneratedColumn()
  notification_preference_id: number;

  @ManyToOne(() => User, (u) => u.notificationPreferences, {
    onDelete: 'CASCADE',
  })
  user: User;

  @Column({ length: 50 })
  code: string;

  @Column({ type: 'boolean', default: true })
  allowed: boolean;
}
