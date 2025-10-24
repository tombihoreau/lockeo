import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { ProductHasCategory } from './product-has-category.entity';

@Entity('categories')
export class Category {
  @PrimaryGeneratedColumn()
  category_id: number;

  @Column({ length: 50, unique: true })
  label: string;

  @OneToMany(() => ProductHasCategory, (phc) => phc.category)
  productCategories: ProductHasCategory[];
}
