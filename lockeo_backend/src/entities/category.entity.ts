import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { ProductHasCategory } from './product-has-category.entity';

@Entity('categories')
export class Category {
  @PrimaryGeneratedColumn()
  category_id: number;

  @Column({ length: 50, unique: true })
  label: string;

  @Column({ type: 'int', default: 0 })
  parent_id: number;

  @OneToMany(() => ProductHasCategory, (phc) => phc.category)
  productCategories: ProductHasCategory[];
}
