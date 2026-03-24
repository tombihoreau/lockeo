import 'dotenv/config';
import { AppDataSource } from './data-source';
import { User } from '../entities/user.entity';
import { Category } from '../entities/category.entity';
import { Product } from '../entities/product.entity';
import { ProductHasCategory } from '../entities/product-has-category.entity';
import { Offer } from '../entities/offer.entity';
import { Reservation } from '../entities/reservation.entity';
import { Review } from '../entities/review.entity';
import { Image } from '../entities/image.entity';
import { Conversation } from '../entities/conversation.entity';
import { Message } from '../entities/message.entity';
import { Favorite } from '../entities/favorite.entity';
import { NotificationTemplate } from '../entities/notification-template.entity';
import { UserNotification } from '../entities/user-notification.entity';
import { NotificationPreference } from '../entities/notification-preference.entity';
import { ProductUnavailability } from '../entities/product-unavailability.entity';
import * as bcrypt from 'bcrypt';

function requireAt<T>(items: T[], index: number, label: string): T {
  const item = items[index];
  if (item == null) {
    throw new Error(`${label} introuvable à l'index ${index}`);
  }
  return item;
}

async function runSeed() {
  await AppDataSource.initialize();
  console.log('DataSource initialisé');

  // Repositories
  const userRepo = AppDataSource.getRepository(User);
  const categoryRepo = AppDataSource.getRepository(Category);
  const productRepo = AppDataSource.getRepository(Product);
  const phcRepo = AppDataSource.getRepository(ProductHasCategory);
  const offerRepo = AppDataSource.getRepository(Offer);
  const reservationRepo = AppDataSource.getRepository(Reservation);
  const reviewRepo = AppDataSource.getRepository(Review);
  const imageRepo = AppDataSource.getRepository(Image);
  const convRepo = AppDataSource.getRepository(Conversation);
  const messageRepo = AppDataSource.getRepository(Message);
  const favoriteRepo = AppDataSource.getRepository(Favorite);
  const notifTplRepo = AppDataSource.getRepository(NotificationTemplate);
  const userNotifRepo = AppDataSource.getRepository(UserNotification);
  const notifPrefRepo = AppDataSource.getRepository(NotificationPreference);
  const unavailabilityRepo = AppDataSource.getRepository(ProductUnavailability);

  // Seed Users
  if ((await userRepo.count()) === 0) {
    const passwordHash = await bcrypt.hash('Password123!', 10);
    const users = [
      userRepo.create({ email: 'alice@example.com', login: 'alice', password_hash: passwordHash, first_name: 'Alice', last_name: 'Martin', city: 'Paris', postal_code: '75001', is_verified: true }),
      userRepo.create({ email: 'bob@example.com', login: 'bob', password_hash: passwordHash, first_name: 'Bob', last_name: 'Durand', city: 'Lyon', postal_code: '69001', is_verified: false }),
      userRepo.create({ email: 'carol@example.com', login: 'carol', password_hash: passwordHash, first_name: 'Carol', last_name: 'Petit', city: 'Marseille', postal_code: '13001', is_verified: true }),
    ];
    await userRepo.save(users);
    console.log('Users insérés');
  }

  // Seed Categories
  if ((await categoryRepo.count()) === 0) {
    const parentCategories = [
      categoryRepo.create({ label: 'Nautique', parent_id: 0 }),
      categoryRepo.create({ label: 'Randonnée', parent_id: 0 }),
      categoryRepo.create({ label: 'Vélo', parent_id: 0 }),
      categoryRepo.create({ label: 'Sport de balle', parent_id: 0 }),
    ];
    await categoryRepo.save(parentCategories);

    const savedParents = await categoryRepo.findBy({ parent_id: 0 });
    const parentByLabel = new Map(
      savedParents.map((category) => [category.label, category]),
    );

    const childDefinitions: Array<{ label: string; parentLabel: string }> = [
      { label: 'Kayak', parentLabel: 'Nautique' },
      { label: 'Plongée', parentLabel: 'Nautique' },
      { label: 'Surf', parentLabel: 'Nautique' },
      { label: 'VTT', parentLabel: 'Vélo' },
      { label: 'Vélos électriques', parentLabel: 'Vélo' },
      { label: 'Vélos de route', parentLabel: 'Vélo' },
      { label: 'Football', parentLabel: 'Sport de balle' },
      { label: 'Basketball', parentLabel: 'Sport de balle' },
      { label: 'Tennis', parentLabel: 'Sport de balle' },
      { label: 'Chaussures de randonnée', parentLabel: 'Randonnée' },
      { label: 'Tentes', parentLabel: 'Randonnée' },
      { label: 'Accessoires de randonnée', parentLabel: 'Randonnée' },
    ];

    const childCategories = childDefinitions.map(({ label, parentLabel }) => {
      const parent = parentByLabel.get(parentLabel);
      if (!parent) {
        throw new Error(`Catégorie parente introuvable pour ${label}`);
      }

      return categoryRepo.create({
        label,
        parent_id: parent.category_id,
      });
    });

    await categoryRepo.save(childCategories);
    console.log('Categories insérées');
  }

  const users = await userRepo.find();
  const categories = await categoryRepo.find();
  const user0 = requireAt(users, 0, 'Utilisateur');
  const user1 = requireAt(users, 1, 'Utilisateur');
  const user2 = requireAt(users, 2, 'Utilisateur');

  // Seed Products
  if ((await productRepo.count()) === 0) {
    const products = [
      productRepo.create({ name: 'VTT Pro', description: 'VTT tout-suspendu en excellent état', price: 25.00, price_3_days: 69.00, price_7_days: 154.00, price_estimate: 900.00, state: 'very_good', city: 'Paris', postal_code: '75001', owner: user0, is_available: true }),
      productRepo.create({ name: 'Tente 2 places', description: 'Légère et compacte', price: 10.00, price_3_days: 27.00, price_7_days: 56.00, price_estimate: 120.00, state: 'good', city: 'Lyon', postal_code: '69001', owner: user1, is_available: true }),
      productRepo.create({ name: 'Chaussures de randonnée', description: 'Imperméables, taille 42', price: 8.00, price_3_days: 22.00, price_7_days: 42.00, price_estimate: 80.00, state: 'used', city: 'Marseille', postal_code: '13001', owner: user2, is_available: true }),
    ];
    await productRepo.save(products);
    console.log('Products insérés');

    // Images
    const product0 = requireAt(products, 0, 'Produit');
    const product1 = requireAt(products, 1, 'Produit');
    const product2 = requireAt(products, 2, 'Produit');
    const images = [
      imageRepo.create({ uri: 'default.jpg', position_image: 0, product: product0 }),
      imageRepo.create({ uri: 'vtt1.jpg', position_image: 1, product: product0 }),
      imageRepo.create({ uri: 'vtt2.jpg', position_image: 2, product: product0 }),
      imageRepo.create({ uri: 'default.jpg', position_image: 0, product: product1 }),
      imageRepo.create({ uri: 'default.jpg', position_image: 0, product: product2 }),
    ];
    await imageRepo.save(images);
    console.log('Images insérées');

    // Lier catégories (simple mapping arbitraire)
    const map: [Product, string[]][] = [
      [product0, ['Vélo', 'VTT']],
      [product1, ['Randonnée', 'Tentes']],
      [product2, ['Randonnée', 'Chaussures de randonnée']],
    ];
    for (const [prod, catLabels] of map) {
      for (const label of catLabels) {
        const c = categories.find((c) => c.label === label);
        if (c) await phcRepo.save(phcRepo.create({ product: prod, category: c }));
      }
    }
    console.log('Associations produit-catégorie insérées');
  }

  const products = await productRepo.find();
  const product0 = requireAt(products, 0, 'Produit');
  const product1 = requireAt(products, 1, 'Produit');

  // Offers
  if ((await offerRepo.count()) === 0) {
    const offers = [
      offerRepo.create({ status: 'open', amount: 25.00, owner: user0, product: product0 }),
      offerRepo.create({ status: 'open', amount: 10.00, owner: user1, product: product1 }),
    ];
    await offerRepo.save(offers);
    console.log('Offers insérées');

    // Reservations
    const offer0 = requireAt(offers, 0, 'Offre');
    const reservations = [
      reservationRepo.create({ start_date: new Date(), end_date: new Date(Date.now() + 2*86400000), status: 'pending', final_price: 50.00, offer: offer0, renter: user1 }),
    ];
    await reservationRepo.save(reservations);
    console.log('Reservations insérées');

    // Reviews
    const reservation0 = requireAt(reservations, 0, 'Réservation');
    const reviews = [
      reviewRepo.create({ rating: 5, comment: 'Super matériel, rien à redire.', user: user1, reservation: reservation0 }),
    ];
    await reviewRepo.save(reviews);
    console.log('Reviews insérées');
  }

  // Favorites
  if ((await favoriteRepo.count()) === 0) {
    const favs = [
      favoriteRepo.create({ user: user1, product: product0 }),
      favoriteRepo.create({ user: user2, product: product0 }),
    ];
    await favoriteRepo.save(favs);
    console.log('Favorites insérées');
  }

  // Notification templates
  if ((await notifTplRepo.count()) === 0) {
    const templates = [
      notifTplRepo.create({ code: 'WELCOME', title: 'Bienvenue', content: 'Bienvenue sur Lockeo!' }),
      notifTplRepo.create({ code: 'OFFER_UPDATE', title: 'Mise à jour offre', content: 'Votre offre a été mise à jour.' }),
    ];
    await notifTplRepo.save(templates);
    console.log('NotificationTemplates insérées');

    // User notifications
    const tmplAll = await notifTplRepo.find();
    const template0 = requireAt(tmplAll, 0, 'Template de notification');
    const template1 = requireAt(tmplAll, 1, 'Template de notification');
    const userNotifications = [
      userNotifRepo.create({ template: template0, destinationUser: user0, status: 'sent' }),
      userNotifRepo.create({ template: template1, destinationUser: user1, status: 'read' }),
    ];
    await userNotifRepo.save(userNotifications);
    console.log('UserNotifications insérées');
  }

  // Notification preferences
  if ((await notifPrefRepo.count()) === 0) {
    const prefs = [
      notifPrefRepo.create({ user: user0, code: 'EMAIL', allowed: true }),
      notifPrefRepo.create({ user: user0, code: 'PUSH', allowed: true }),
      notifPrefRepo.create({ user: user1, code: 'EMAIL', allowed: false }),
    ];
    await notifPrefRepo.save(prefs);
    console.log('NotificationPreferences insérées');
  }

  // Conversations & messages
  if ((await convRepo.count()) === 0) {
    const conv = convRepo.create({ renter: user1, owner: user0, created_at: new Date() });
    await convRepo.save(conv);
    const msgs = [
      messageRepo.create({ conversation: conv, sender: user1, content: 'Bonjour, le VTT est-il disponible ?', created_at: new Date() }),
      messageRepo.create({ conversation: conv, sender: user0, content: 'Oui, il est disponible cette semaine.', created_at: new Date() }),
    ];
    await messageRepo.save(msgs);
    console.log('Conversation et Messages insérés');
  }

  // Product unavailabilities
  if ((await unavailabilityRepo.count()) === 0) {
    const unav = unavailabilityRepo.create({ product: product0, start_date_time: new Date(Date.now() + 3*86400000), end_date_time: new Date(Date.now() + 5*86400000) });
    await unavailabilityRepo.save(unav);
    console.log('ProductUnavailability insérée');
  }

  console.log('Seed terminé avec succès');
  await AppDataSource.destroy();
}

runSeed().catch(err => {
  console.error('Erreur seed:', err);
  process.exit(1);
});
