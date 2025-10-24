import { Entity, PrimaryGeneratedColumn, ManyToOne, Column } from 'typeorm';
import { User } from './user.entity';
import { Product } from './product.entity';

@Entity('favorites')
export class Favorite {
  @PrimaryGeneratedColumn()
  favorite_id: number;

  @ManyToOne(() => User, (u) => u.favorites, { onDelete: 'CASCADE' })
  user: User;

  @ManyToOne(() => Product, { onDelete: 'CASCADE' })
  product: Product;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;
}
