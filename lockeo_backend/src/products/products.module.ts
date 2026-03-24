import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Product } from '../entities/product.entity';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { User } from '../entities/user.entity';
import { Offer } from '../entities/offer.entity';
import { Image } from '../entities/image.entity';
import { Category } from '../entities/category.entity';
import { ProductHasCategory } from '../entities/product-has-category.entity';
import { ProductUnavailability } from '../entities/product-unavailability.entity';
import { MessagingModule } from '../messaging/messaging.module';

@Module({
  imports: [
    MessagingModule,
    TypeOrmModule.forFeature([
      Product,
      User,
      Offer,
      Image,
      Category,
      ProductHasCategory,
      ProductUnavailability,
    ]),
  ],
  providers: [ProductsService],
  controllers: [ProductsController],
  exports: [ProductsService],
})
export class ProductsModule {}
