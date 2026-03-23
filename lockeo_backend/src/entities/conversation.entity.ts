import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  JoinColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Message } from './message.entity';
import { Reservation } from './reservation.entity';

@Entity('conversations')
export class Conversation {
  @PrimaryGeneratedColumn()
  conversation_id: number;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;

  // participants
  @ManyToOne(() => User, (u) => u.conversationsAsRenter, {
    onDelete: 'CASCADE',
  })
  renter: User;

  @ManyToOne(() => User, (u) => u.conversationsAsOwner, { onDelete: 'CASCADE' })
  owner: User;

  @ManyToOne(() => Reservation, (reservation) => reservation.conversations, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({
    name: 'reservationReservationId',
    referencedColumnName: 'reservation_id',
  })
  reservation: Reservation | null;

  @OneToMany(() => Message, (m) => m.conversation, { cascade: true })
  messages: Message[];
}
