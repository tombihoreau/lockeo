import { Controller, Get, Query } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductSuggestionDto } from './products.service';

@Controller('products')
export class ProductsController {
  constructor(private readonly products: ProductsService) {}

  @Get('suggestions')
  async suggestions(@Query('limit') limit = '4'): Promise<ProductSuggestionDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '4', 10) || 4, 20));
    return this.products.getSuggestions(take);
  }
}
