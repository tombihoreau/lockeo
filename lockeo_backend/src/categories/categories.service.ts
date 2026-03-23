import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from '../entities/category.entity';

export interface CategoryDto {
  category_id: number;
  label: string;
  parent_id: number;
}

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category) private readonly repo: Repository<Category>,
  ) {}

  async findAll(): Promise<CategoryDto[]> {
    const categories = await this.repo.find({
      order: {
        parent_id: 'ASC',
        label: 'ASC',
      },
    });

    return categories.map((c) => ({
      category_id: c.category_id,
      label: c.label,
      parent_id: c.parent_id ?? 0,
    }));
  }
}
