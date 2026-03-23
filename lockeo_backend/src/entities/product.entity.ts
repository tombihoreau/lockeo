import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Offer } from './offer.entity';
import { Image } from './image.entity';
import { ProductHasCategory } from './product-has-category.entity';
import { ProductUnavailability } from './product-unavailability.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  product_id: number;

  @Column({ length: 50 }) name: string;
  @Column({ type: 'text', nullable: true }) description: string;

  @Column({ type: 'decimal', precision: 8, scale: 2 }) price: number;
  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true }) price_3_days: number;
  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true }) price_7_days: number;
  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true }) price_estimate: number;

  @Column({ length: 50 }) state: string;

  @Column({ type: 'float', nullable: true }) longitude: number;
  @Column({ type: 'float', nullable: true }) latitude: number;
  @Column({ length: 50 }) city: string;
  @Column({ length: 10 }) postal_code: string;

  @Column({ type: 'boolean', default: true }) is_available: boolean;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;
  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  updated_at: Date;

  // Owner
  @ManyToOne(() => User, (u) => u.products, { onDelete: 'CASCADE' })
  owner: User;

  @OneToMany(() => Offer, (o) => o.product) offers: Offer[];
  @OneToMany(() => Image, (i) => i.product, { cascade: true }) images: Image[];
  @OneToMany(() => ProductHasCategory, (phc) => phc.product, { cascade: true })
  productCategories: ProductHasCategory[];
  @OneToMany(() => ProductUnavailability, (pu) => pu.product, { cascade: true })
  unavailabilities: ProductUnavailability[];
}
