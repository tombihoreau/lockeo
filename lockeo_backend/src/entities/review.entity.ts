import {
  Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToOne, JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Reservation } from './reservation.entity';

@Entity('reviews')
export class Review {
  @PrimaryGeneratedColumn()
  review_id: number;

  @Column({ type: 'int' }) rating: number;
  @Column({ type: 'text', nullable: true }) comment: string;
  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' }) created_at: Date;

  @ManyToOne(() => User, (u) => u.reviews, { onDelete: 'CASCADE' })
  user: User;

  @OneToOne(() => Reservation, (r) => r.review, { onDelete: 'CASCADE' })
  @JoinColumn()
  reservation: Reservation;
}
