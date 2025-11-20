import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToOne } from 'typeorm';
import { Offer } from './offer.entity';
import { User } from './user.entity';
import { Review } from './review.entity';

@Entity('reservations')
export class Reservation {
  @PrimaryGeneratedColumn()
  reservation_id: number;

  @Column({ type: 'datetime' }) start_date: Date;
  @Column({ type: 'datetime' }) end_date: Date;

  @Column({ length: 50 }) status: string;
  @Column({ type: 'decimal', precision: 8, scale: 2 }) final_price: number;
  @Column({ length: 50, nullable: true }) verification_code: string;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' }) created_at: Date;
  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' }) updated_at: Date;

  @ManyToOne(() => Offer, (o) => o.reservations, { onDelete: 'CASCADE' })
  offer: Offer;

  // L'utilisateur qui loue (renter)
  @ManyToOne(() => User, (u) => u.reservationsAsRenter, { onDelete: 'CASCADE' })
  renter: User;

  // 1–1 Review (facultatif)
  @OneToOne(() => Review, (rv) => rv.reservation)
  review: Review;
}
  