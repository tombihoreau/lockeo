import { Entity, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { Product } from './product.entity';
import { Category } from './category.entity';

@Entity('products_has_categories')
export class ProductHasCategory {
  @PrimaryGeneratedColumn()
  product_has_category_id: number;

  @ManyToOne(() => Product, (p) => p.productCategories, { onDelete: 'CASCADE' })
  product: Product;

  @ManyToOne(() => Category, (c) => c.productCategories, {
    onDelete: 'CASCADE',
  })
  category: Category;
}
