import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { User } from './entities/user.entity';
import { Product } from './entities/product.entity';
import { Offer } from './entities/offer.entity';
import { Reservation } from './entities/reservation.entity';
import { Review } from './entities/review.entity';
import { Favorite } from './entities/favorite.entity';
import { Conversation } from './entities/conversation.entity';
import { Message } from './entities/message.entity';
import { MessageTemplate } from './entities/message-template.entity';
import { Image } from './entities/image.entity';
import { ProductUnavailability } from './entities/product-unavailability.entity';
import { Category } from './entities/category.entity';
import { ProductHasCategory } from './entities/product-has-category.entity';
import { NotificationTemplate } from './entities/notification-template.entity';
import { UserNotification } from './entities/user-notification.entity';
import { NotificationPreference } from './entities/notification-preference.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [UsersModule, ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'mysql',
        host: config.get<string>('DB_HOST'),
        port: parseInt(config.get<string>('DB_PORT', '3306')),
        username: config.get<string>('DB_USER'),
        password: config.get<string>('DB_PASS'),
        database: config.get<string>('DB_NAME'),
        autoLoadEntities: true,
        entities: [
      User, Product, Offer, Reservation, Review, Favorite,
      Conversation, Message, MessageTemplate, Image,
      ProductUnavailability, Category, ProductHasCategory,
      NotificationTemplate, UserNotification, NotificationPreference,
    ],
        synchronize: true, // ⚠️ Ne jamais laisser en prod
      }),
    }),
    UsersModule, AuthModule],
  controllers: [AppController],
  providers: [AppService]
})
export class AppModule {}
