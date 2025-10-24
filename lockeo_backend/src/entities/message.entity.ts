import {
  Entity, PrimaryGeneratedColumn, Column, ManyToOne,
} from 'typeorm';
import { Conversation } from './conversation.entity';
import { User } from './user.entity';

@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn()
  message_id: number;

  @Column({ type: 'varchar', length: 500 })
  content: string;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;

  @ManyToOne(() => Conversation, (c) => c.messages, { onDelete: 'CASCADE' })
  conversation: Conversation;

  @ManyToOne(() => User, (u) => u.messages, { onDelete: 'CASCADE' })
  sender: User;
}
