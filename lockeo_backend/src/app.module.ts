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
import { CategoriesModule } from './categories/categories.module';
import { ProductsModule } from './products/products.module';
import { FavoritesModule } from './favorites/favorites.module';
import { ProductHasCategory } from './entities/product-has-category.entity';
import { NotificationTemplate } from './entities/notification-template.entity';
import { UserNotification } from './entities/user-notification.entity';
import { NotificationPreference } from './entities/notification-preference.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { join } from 'path';
import { MessagingModule } from './messaging/messaging.module';

@Module({
  imports: [
    UsersModule,
    ConfigModule.forRoot({ isGlobal: true }),
    CategoriesModule,
    ProductsModule,
    FavoritesModule,
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const nodeEnv = config.get<string>('NODE_ENV', 'development');
        const isProd = nodeEnv === 'production';
        // Keep schema changes controlled through migrations by default.
        const synchronize =
          config.get<string>('DB_SYNCHRONIZE', 'false') === 'true';
        const dropSchema =
          config.get<string>('DB_DROP_SCHEMA', 'false') === 'true';

        return {
          type: 'mysql',
          host: config.get<string>('DB_HOST'),
          port: parseInt(config.get<string>('DB_PORT', '3306')),
          username: config.get<string>('DB_USER'),
          password: config.get<string>('DB_PASS'),
          database: config.get<string>('DB_NAME'),
          autoLoadEntities: true,
          entities: [
            User,
            Product,
            Offer,
            Reservation,
            Review,
            Favorite,
            Conversation,
            Message,
            MessageTemplate,
            Image,
            ProductUnavailability,
            Category,
            ProductHasCategory,
            NotificationTemplate,
            UserNotification,
            NotificationPreference,
          ],
          // Dev/test: autoriser la synchro et (optionnel) drop de schéma
          synchronize,
          dropSchema,
          // Prod: utiliser les migrations compilées
          migrations: [join(__dirname, 'database', 'migrations', '*.js')],
          migrationsRun: isProd,
        } as const;
      },
    }),
    AuthModule,
    MessagingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
