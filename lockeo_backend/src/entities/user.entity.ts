import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
} from 'typeorm';
import { Message } from './message.entity';
import { Product } from './product.entity';
import { Reservation } from './reservation.entity';
import { Review } from './review.entity';
import { NotificationPreference } from './notification-preference.entity';
import { Favorite } from './favorite.entity';
import { Offer } from './offer.entity';
import { Conversation } from './conversation.entity';
import { UserNotification } from './user-notification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  user_id: number;

  // Identité & sécurité
  @Column({ length: 100, unique: true })
  email: string;

  @Column({ type: 'varchar', length: 100, unique: true, nullable: true })
  login: string | null;

  @Column({ length: 255 })
  password_hash: string;

  // Informations de profil
  @Column({ length: 50, nullable: true })
  first_name: string;

  @Column({ length: 50, nullable: true })
  last_name: string;

  @Column({ length: 20, nullable: true })
  phone_number: string;

  // Localisation
  @Column({ type: 'float', nullable: true })
  longitude: number;

  @Column({ type: 'float', nullable: true })
  latitude: number;

  @Column({ length: 50, nullable: true })
  city: string;

  @Column({ length: 10, nullable: true })
  postal_code: string;

  // Statuts
  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  // Audit
  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  updated_at: Date;

  // Relations
  @OneToMany(() => Message, (m) => m.sender)
  messages: Message[];

  @OneToMany(() => Product, (p) => p.owner)
  products: Product[];

  @OneToMany(() => Reservation, (r) => r.renter)
  reservationsAsRenter: Reservation[];

  @OneToMany(() => Review, (rv) => rv.user)
  reviews: Review[];

  @OneToMany(() => NotificationPreference, (np) => np.user)
  notificationPreferences: NotificationPreference[];

  @OneToMany(() => Favorite, (f) => f.user)
  favorites: Favorite[];

  @OneToMany(() => Offer, (o) => o.owner)
  offers: Offer[];

  @OneToMany(() => Conversation, (c) => c.renter)
  conversationsAsRenter: Conversation[];

  @OneToMany(() => Conversation, (c) => c.owner)
  conversationsAsOwner: Conversation[];

  @OneToMany(() => UserNotification, (un) => un.destinationUser)
  notifications: UserNotification[];
}
