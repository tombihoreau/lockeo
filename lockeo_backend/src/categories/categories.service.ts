import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from '../entities/category.entity';

export interface CategoryDto {
  category_id: number;
  label: string;
}

@Injectable()
export class CategoriesService {
  constructor(@InjectRepository(Category) private readonly repo: Repository<Category>) {}

  async findAll(): Promise<CategoryDto[]> {
    const categories = await this.repo.find();
    return categories.map((c) => ({
      category_id: c.category_id,
      label: c.label,
    }));
  }
}
