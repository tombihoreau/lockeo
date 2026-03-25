import 'dotenv/config';
import { copyFileSync, existsSync, rmSync } from 'fs';
import { basename, extname, join, resolve } from 'path';
import { AppDataSource } from './data-source';
import { Category } from '../entities/category.entity';
import { Image } from '../entities/image.entity';
import { Offer } from '../entities/offer.entity';
import { Product } from '../entities/product.entity';
import { ProductHasCategory } from '../entities/product-has-category.entity';
import { User } from '../entities/user.entity';
import { ensureProductUploadsDir } from '../uploads/uploads-path';

type DemoUserSeed = {
  email: string;
  login: string;
  firstName: string;
  lastName: string;
  city: string;
  postalCode: string;
  latitude: number;
  longitude: number;
};

type DemoCategorySeed = {
  label: string;
  children: string[];
};

type DemoProductSeed = {
  name: string;
  description: string;
  price: number;
  price3Days: number;
  price7Days: number;
  priceEstimate: number;
  state: string;
  city: string;
  postalCode: string;
  latitude: number;
  longitude: number;
  ownerLogin: string;
  categories: [string, string];
  sourceImages: string[];
};

const demoUsers: DemoUserSeed[] = [
  {
    email: 'nautique.demo@lockeo.fr',
    login: 'nautique.demo',
    firstName: 'Lina',
    lastName: 'Renaud',
    city: 'Quimper',
    postalCode: '29000',
    latitude: 47.9961,
    longitude: -4.1025,
  },
  {
    email: 'velo.demo@lockeo.fr',
    login: 'velo.demo',
    firstName: 'Chloe',
    lastName: 'Bernard',
    city: 'Rennes',
    postalCode: '35000',
    latitude: 48.1173,
    longitude: -1.6778,
  },
];

const demoPasswordHash =
  '$2b$12$DjVCkcP4B1.skmXADXZMJ.zm15WInfALbGO0jMNQ8DZIIz7FwCsJa';

const demoCategories: DemoCategorySeed[] = [
  {
    label: 'Nautique',
    children: ['Paddle', 'Kayak', 'Surf'],
  },
  {
    label: 'Camping & bivouac',
    children: ['Tentes', 'Kits bivouac', 'Couchage'],
  },
  {
    label: 'Randonnée',
    children: ['Sacs à dos', 'Chaussures', 'Accessoires'],
  },
  {
    label: 'Vélo',
    children: ['VTT', 'Vélo urbain', 'Vélo enfant'],
  },
  {
    label: 'Sports collectifs',
    children: ['Football', 'Basketball', 'Volleyball'],
  },
];

const demoProducts: DemoProductSeed[] = [
  {
    name: 'Paddle touring gonflable',
    description:
      'Planche stable et legere, ideale pour les balades en mer calme ou sur lac. Livree avec pompe, pagaie reglable et sac de transport.',
    price: 24,
    price3Days: 65,
    price7Days: 145,
    priceEstimate: 420,
    state: 'Très bon',
    city: 'Quimper',
    postalCode: '29000',
    latitude: 47.9961,
    longitude: -4.1025,
    ownerLogin: 'nautique.demo',
    categories: ['Nautique', 'Paddle'],
    sourceImages: ['paddle_touring.jpg', 'paddle.jpg'],
  },
  {
    name: 'Kayak randonnée 1 place',
    description:
      'Kayak maniable pour sortie a la demi-journee ou a la journee. Siege reglable, gilet et pagaie inclus.',
    price: 29,
    price3Days: 78,
    price7Days: 175,
    priceEstimate: 690,
    state: 'Bon',
    city: 'Crozon',
    postalCode: '29160',
    latitude: 48.2454,
    longitude: -4.4893,
    ownerLogin: 'nautique.demo',
    categories: ['Nautique', 'Kayak'],
    sourceImages: ['kayak_randonnee.jpg'],
  },
  {
    name: 'Pack kayaks famille',
    description:
      'Quatre kayaks rigides parfaits pour une sortie en duo ou avec enfants. Lot complet avec deux pagaies et gilets.',
    price: 45,
    price3Days: 122,
    price7Days: 275,
    priceEstimate: 1200,
    state: 'Bon',
    city: 'Douarnenez',
    postalCode: '29100',
    latitude: 48.0958,
    longitude: -4.3294,
    ownerLogin: 'nautique.demo',
    categories: ['Nautique', 'Kayak'],
    sourceImages: ['kayaks_lot.jpg', 'kayaks.jpg'],
  },
  {
    name: 'Planche de surf shortboard',
    description:
      'Shortboard reactive pour niveau intermediaire. Housse de transport et leash fournis.',
    price: 22,
    price3Days: 60,
    price7Days: 132,
    priceEstimate: 380,
    state: 'Très bon',
    city: 'Plomeur',
    postalCode: '29120',
    latitude: 47.8407,
    longitude: -4.2835,
    ownerLogin: 'nautique.demo',
    categories: ['Nautique', 'Surf'],
    sourceImages: ['planche_surf.jpg', 'planche.jpg'],
  },
  {
    name: 'Tente dôme 2 places',
    description:
      'Tente compacte pour randonnee ou week-end camping. Double toit, tapis de sol integre et montage rapide.',
    price: 16,
    price3Days: 42,
    price7Days: 88,
    priceEstimate: 180,
    state: 'Très bon',
    city: 'Paimpont',
    postalCode: '35380',
    latitude: 48.0186,
    longitude: -2.1719,
    ownerLogin: 'velo.demo',
    categories: ['Camping & bivouac', 'Tentes'],
    sourceImages: ['tente_dome.jpg', 'tente_dome2.jpg'],
  },
  {
    name: 'Kit bivouac 3 saisons',
    description:
      'Ensemble pret a partir avec rechaud, popote, lampe frontale et accessoires essentiels pour deux personnes.',
    price: 19,
    price3Days: 51,
    price7Days: 110,
    priceEstimate: 250,
    state: 'Bon',
    city: 'Fougères',
    postalCode: '35300',
    latitude: 48.3519,
    longitude: -1.2021,
    ownerLogin: 'velo.demo',
    categories: ['Camping & bivouac', 'Kits bivouac'],
    sourceImages: ['kit_bivouac.jpg'],
  },
  {
    name: 'Sac de randonnée 50L',
    description:
      'Sac confortable avec armature legere, housse pluie et multiples rangements. Convient pour trek de 2 a 4 jours.',
    price: 12,
    price3Days: 32,
    price7Days: 68,
    priceEstimate: 140,
    state: 'Très bon',
    city: 'Bécherel',
    postalCode: '35190',
    latitude: 48.2964,
    longitude: -1.9446,
    ownerLogin: 'velo.demo',
    categories: ['Randonnée', 'Sacs à dos'],
    sourceImages: ['sac_randonnee.jpg'],
  },
  {
    name: 'VTT tout suspendu trail',
    description:
      'VTT adulte polyvalent pour chemins et singles roulants. Freins a disque, suspension revisee et casque disponible en option.',
    price: 34,
    price3Days: 92,
    price7Days: 205,
    priceEstimate: 1450,
    state: 'Très bon',
    city: 'Saint-Malo',
    postalCode: '35400',
    latitude: 48.6493,
    longitude: -2.0257,
    ownerLogin: 'velo.demo',
    categories: ['Vélo', 'VTT'],
    sourceImages: ['vtt1.jpg', 'vtt2.jpg', 'vtt3.jpg'],
  },
  {
    name: 'Vélo pliant urbain',
    description:
      'Velo pratique pour deplacements en ville et trajets multimodaux. Se replie rapidement pour coffre ou train.',
    price: 18,
    price3Days: 49,
    price7Days: 104,
    priceEstimate: 520,
    state: 'Bon',
    city: 'Rennes',
    postalCode: '35000',
    latitude: 48.1173,
    longitude: -1.6778,
    ownerLogin: 'velo.demo',
    categories: ['Vélo', 'Vélo urbain'],
    sourceImages: ['velo_pliant.jpg'],
  },
  {
    name: 'Vélo enfant 20 pouces',
    description:
      'Velo enfant pour sorties en famille, avec bequille et eclairage. Convient environ de 6 a 9 ans.',
    price: 11,
    price3Days: 29,
    price7Days: 60,
    priceEstimate: 210,
    state: 'Bon',
    city: 'Vannes',
    postalCode: '56000',
    latitude: 47.6582,
    longitude: -2.7608,
    ownerLogin: 'velo.demo',
    categories: ['Vélo', 'Vélo enfant'],
    sourceImages: ['velo_enfant.jpg', 'velo_enfants.jpg'],
  },
  {
    name: 'Ballon de football match',
    description:
      'Ballon taille 5 pour entrainement ou match amateur, gonfle et pret a jouer.',
    price: 6,
    price3Days: 15,
    price7Days: 28,
    priceEstimate: 35,
    state: 'Neuf',
    city: 'Lorient',
    postalCode: '56100',
    latitude: 47.7482,
    longitude: -3.3702,
    ownerLogin: 'velo.demo',
    categories: ['Sports collectifs', 'Football'],
    sourceImages: ['football_ballon.jpg'],
  },
];

const tablesToTruncate = [
  'messages',
  'conversations',
  'reviews',
  'reservations',
  'favorites',
  'user_notifications',
  'notification_preferences',
  'offers',
  'product_unavailabilities',
  'products_has_categories',
  'images',
  'products',
  'notification_templates',
  'message_templates',
  'categories',
  'users',
];

function slugify(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .toLowerCase();
}

function resolveSeedImageSourceDir(): string {
  const explicitDir = process.env.SEED_IMAGE_SOURCE_DIR?.trim();
  if (explicitDir) {
    return resolve(explicitDir);
  }

  const candidates = [
    resolve(join(process.cwd(), 'seed-assets', 'products')),
    resolve(join(process.cwd(), '..', 'lockeo_app', 'assets', 'images')),
  ];

  const existingDir = candidates.find((candidate) => existsSync(candidate));
  if (!existingDir) {
    throw new Error(
      [
        'Impossible de trouver un dossier source pour les images de seed.',
        'Definissez SEED_IMAGE_SOURCE_DIR ou placez les images dans lockeo_backend/seed-assets/products.',
      ].join(' '),
    );
  }

  return existingDir;
}

function cleanProductUploadsDir(productUploadsDir: string): void {
  if (existsSync(productUploadsDir)) {
    rmSync(productUploadsDir, { recursive: true, force: true });
  }
  ensureProductUploadsDir();
}

function copySeedImage(
  sourceDir: string,
  productUploadsDir: string,
  productSlug: string,
  imageName: string,
  position: number,
): string {
  const sourcePath = join(sourceDir, imageName);
  if (!existsSync(sourcePath)) {
    throw new Error(`Image de seed introuvable: ${sourcePath}`);
  }

  const extension = extname(imageName).toLowerCase() || '.jpg';
  const targetFileName = `${productSlug}-${String(position + 1).padStart(2, '0')}${extension}`;
  const targetPath = join(productUploadsDir, targetFileName);

  copyFileSync(sourcePath, targetPath);
  return `uploads/products/${basename(targetPath)}`;
}

async function truncateBusinessTables(): Promise<void> {
  const queryRunner = AppDataSource.createQueryRunner();
  await queryRunner.connect();

  try {
    await queryRunner.query('SET FOREIGN_KEY_CHECKS = 0');
    for (const table of tablesToTruncate) {
      await queryRunner.query(`TRUNCATE TABLE \`${table}\``);
    }
    await queryRunner.query('SET FOREIGN_KEY_CHECKS = 1');
  } finally {
    await queryRunner.release();
  }
}

async function runSeed() {
  await AppDataSource.initialize();
  console.log('DataSource initialise');

  const userRepo = AppDataSource.getRepository(User);
  const categoryRepo = AppDataSource.getRepository(Category);
  const productRepo = AppDataSource.getRepository(Product);
  const productCategoryRepo = AppDataSource.getRepository(ProductHasCategory);
  const imageRepo = AppDataSource.getRepository(Image);
  const offerRepo = AppDataSource.getRepository(Offer);

  const productUploadsDir = ensureProductUploadsDir();
  const seedImageSourceDir = resolveSeedImageSourceDir();

  console.log('Suppression des donnees actuelles...');
  await truncateBusinessTables();
  cleanProductUploadsDir(productUploadsDir);

  console.log('Creation des utilisateurs de demonstration...');
  const savedUsers = await userRepo.save(
    demoUsers.map((user) =>
      userRepo.create({
        email: user.email,
        login: user.login,
        password_hash: demoPasswordHash,
        first_name: user.firstName,
        last_name: user.lastName,
        city: user.city,
        postal_code: user.postalCode,
        latitude: user.latitude,
        longitude: user.longitude,
        is_verified: true,
      }),
    ),
  );
  const userByLogin = new Map(
    savedUsers.map((user) => [user.login ?? '', user]),
  );

  console.log('Creation des categories et sous-categories...');
  const parentCategories = await categoryRepo.save(
    demoCategories.map((category) =>
      categoryRepo.create({ label: category.label, parent_id: 0 }),
    ),
  );
  const parentByLabel = new Map(
    parentCategories.map((category) => [category.label, category]),
  );

  const childCategories = await categoryRepo.save(
    demoCategories.flatMap((category) =>
      category.children.map((childLabel) => {
        const parent = parentByLabel.get(category.label);
        if (!parent) {
          throw new Error(`Categorie parente introuvable pour ${childLabel}`);
        }

        return categoryRepo.create({
          label: childLabel,
          parent_id: parent.category_id,
        });
      }),
    ),
  );
  const categoryByLabel = new Map(
    [...parentCategories, ...childCategories].map((category) => [
      category.label,
      category,
    ]),
  );

  console.log('Creation des produits et des offres...');
  for (const definition of demoProducts) {
    const owner = userByLogin.get(definition.ownerLogin);
    if (!owner) {
      throw new Error(`Utilisateur introuvable pour ${definition.name}`);
    }

    const product = await productRepo.save(
      productRepo.create({
        name: definition.name,
        description: definition.description,
        price: definition.price,
        price_3_days: definition.price3Days,
        price_7_days: definition.price7Days,
        price_estimate: definition.priceEstimate,
        state: definition.state,
        city: definition.city,
        postal_code: definition.postalCode,
        latitude: definition.latitude,
        longitude: definition.longitude,
        owner,
        is_available: true,
      }),
    );

    for (const categoryLabel of definition.categories) {
      const category = categoryByLabel.get(categoryLabel);
      if (!category) {
        throw new Error(
          `Categorie "${categoryLabel}" introuvable pour ${definition.name}`,
        );
      }

      await productCategoryRepo.save(
        productCategoryRepo.create({
          product,
          category,
        }),
      );
    }

    const productSlug = slugify(definition.name);
    const imageUris = definition.sourceImages.map((imageName, index) =>
      copySeedImage(
        seedImageSourceDir,
        productUploadsDir,
        productSlug,
        imageName,
        index,
      ),
    );

    await imageRepo.save(
      imageUris.map((uri, index) =>
        imageRepo.create({
          uri,
          position_image: index,
          product,
        }),
      ),
    );

    await offerRepo.save(
      offerRepo.create({
        status: 'open',
        amount: definition.price,
        owner,
        product,
      }),
    );
  }

  console.log('Seed termine avec succes');
  console.log(`Images copiees depuis: ${seedImageSourceDir}`);
  console.log(`Images servies depuis: ${productUploadsDir}`);
  console.log('Hash de mot de passe demo applique aux 2 utilisateurs.');

  await AppDataSource.destroy();
}

runSeed().catch((error) => {
  console.error('Erreur seed:', error);
  process.exit(1);
});
