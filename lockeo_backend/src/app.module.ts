import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ProductsModule } from './products/products.module';
import { ConversationsController } from './conversations/conversations.controller';
import { ConversationsModule } from './conversations/conversations.module';
import { ReservationsService } from './reservations/reservations.service';
import { ReservationsController } from './reservations/reservations.controller';
import { ReservationsModule } from './reservations/reservations.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [ProductsModule, ConversationsModule, ReservationsModule, UsersModule],
  controllers: [AppController, ConversationsController, ReservationsController],
  providers: [AppService, ReservationsService],
})
export class AppModule {}
