import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Product } from './product.entity';
import { Reservation } from './reservation.entity';

@Entity('offers')
export class Offer {
  @PrimaryGeneratedColumn()
  offer_id: number;

  @Column({ length: 50 }) status: string;
  @Column({ type: 'decimal', precision: 8, scale: 2 }) amount: number;
  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;

  @ManyToOne(() => User, (u) => u.offers, { onDelete: 'CASCADE' })
  owner: User;

  @ManyToOne(() => Product, (p) => p.offers, { onDelete: 'CASCADE' })
  product: Product;

  @OneToMany(() => Reservation, (r) => r.offer) reservations: Reservation[];
}
