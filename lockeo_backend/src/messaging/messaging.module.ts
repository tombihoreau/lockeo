import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule } from '@nestjs/config';
import { Conversation } from '../entities/conversation.entity';
import { Message } from '../entities/message.entity';
import { NotificationTemplate } from '../entities/notification-template.entity';
import { UserNotification } from '../entities/user-notification.entity';
import { User } from '../entities/user.entity';
import { MessagingService } from './messaging.service';
import { MessagingGateway } from './messaging.gateway';
import { MessagingController } from './messaging.controller';

@Module({
  imports: [
    ConfigModule,
    JwtModule,
    TypeOrmModule.forFeature([
      Conversation,
      Message,
      NotificationTemplate,
      UserNotification,
      User,
    ]),
  ],
  controllers: [MessagingController],
  providers: [MessagingService, MessagingGateway],
  exports: [MessagingService, MessagingGateway],
})
export class MessagingModule {}
