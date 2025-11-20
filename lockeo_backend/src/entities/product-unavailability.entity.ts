import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Product } from './product.entity';

@Entity('product_unavailabilities')
export class ProductUnavailability {
  @PrimaryGeneratedColumn()
  unavailability_id: number;

  @Column({ type: 'datetime' })
  start_date_time: Date;

  @Column({ type: 'datetime' })
  end_date_time: Date;

  @ManyToOne(() => Product, (p) => p.unavailabilities, { onDelete: 'CASCADE' })
  product: Product;
}
