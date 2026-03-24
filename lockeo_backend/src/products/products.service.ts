import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, EntityManager, In, Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { Image } from '../entities/image.entity';
import { User } from '../entities/user.entity';
import { Offer } from '../entities/offer.entity';
import { Category } from '../entities/category.entity';
import { ProductHasCategory } from '../entities/product-has-category.entity';
import { ProductUnavailability } from '../entities/product-unavailability.entity';
import { Reservation } from '../entities/reservation.entity';
import { Review } from '../entities/review.entity';
import { Conversation } from '../entities/conversation.entity';
import { CreateOfferDto } from './dto/create-offer.dto';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { CheckoutReservationDto } from './dto/checkout-reservation.dto';
import { PaymentsService } from './payments.service';

export interface ProductDto {
  product_id: number;
  name: string;
  description: string | null;
  category_ids: number[];
  price: string | number | null;
  price_3_days: string | number | null;
  price_7_days: string | number | null;
  price_estimate: string | number | null;
  state: string;
  longitude: number | null;
  latitude: number | null;
  city: string;
  postal_code: string;
  is_available: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface ProductSuggestionDto {
  product_id: ProductDto['product_id'];
  name: ProductDto['name'];
  description: ProductDto['description'];
  category_ids: ProductDto['category_ids'];
  price: ProductDto['price'];
  price_3_days: ProductDto['price_3_days'];
  price_7_days: ProductDto['price_7_days'];
  price_estimate: ProductDto['price_estimate'];
  state: ProductDto['state'];
  longitude: ProductDto['longitude'];
  latitude: ProductDto['latitude'];
  city: ProductDto['city'];
  postal_code: ProductDto['postal_code'];
  is_available: ProductDto['is_available'];
  created_at: ProductDto['created_at'];
  updated_at: ProductDto['updated_at'];
  image_uri?: string | null;
  offer_id?: number | null;
  offer_user_id?: number | null;
  offer_status?: string | null;
  offer_amount?: string | number | null;
  offer_created_at?: Date | null;
}

export interface ProductOwnerDto {
  user_id: number;
  first_name: string | null;
  last_name: string | null;
  email: string | null;
  login: string | null;
  phone_number: string | null;
  longitude: number | null;
  latitude: number | null;
  postal_code: string | null;
  city: string | null;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface ProductImageDto {
  image_id: number;
  product_id: number;
  url: string;
  position_image: number;
  created_at: Date;
}

export interface ProductUnavailabilityDto {
  unavailability_id: number;
  product_id: number;
  start_date_time: Date;
  end_date_time: Date;
}

export interface ProductCategoryDto {
  category_id: number;
  label: string;
  parent_id: number;
}

export interface ProductDetailDto {
  offer: {
    offer_id: number;
    product_id: number;
    user_id: number;
    status: string;
    amount: string | number;
    created_at: Date;
  };
  product: ProductDto;
  owner: ProductOwnerDto;
  images: ProductImageDto[];
  categories: ProductCategoryDto[];
  unavailabilities: ProductUnavailabilityDto[];
  rental_count: number;
  owner_reviews_count: number;
  owner_rating_average: number;
  owner_offers_count: number;
  other_offers: ProductSuggestionDto[];
}

export interface CreatedOfferDto {
  product_id: number;
  offer_id: number;
}

export interface CreatedReservationDto {
  reservation_id: number;
  conversation_id: number;
}

export interface ReservationCheckoutDto extends CreatedReservationDto {
  payment_provider: 'mock_demo' | 'stripe_test';
  payment_status: 'succeeded';
  payment_reference: string;
  payment_card_label: string;
  payment_card_preview: string;
}

export interface UpdatedReservationStatusDto {
  reservation_id: number;
  status: string;
}

function sanitizePostalCode(value: string | null | undefined): string {
  const normalized = (value ?? '').trim();
  if (!normalized) return '';
  return /^0+$/.test(normalized) ? '' : normalized;
}

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product) private readonly repo: Repository<Product>,
    private readonly paymentsService: PaymentsService,
  ) {}

  async getSuggestions(limit: number): Promise<ProductSuggestionDto[]> {
    const rawIds = await this.repo
      .createQueryBuilder('p')
      .select('p.product_id', 'id')
      .distinct(true)
      .leftJoin('p.offers', 'offer', 'offer.status = :status', {
        status: 'open',
      })
      .where('p.is_available = :avail', { avail: true })
      .andWhere('offer.offer_id IS NOT NULL')
      .orderBy('RAND()')
      .limit(limit)
      .getRawMany<{ id: number }>();

    const ids = rawIds.map((r) => r.id);
    if (ids.length === 0) return [];

    const products = await this.loadProductsForListing(ids);

    const order = new Map<number, number>(ids.map((id, i) => [id, i]));
    products.sort(
      (a, b) => order.get(a.product_id)! - order.get(b.product_id)!,
    );

    return products.map((p) => this.toSuggestionDto(p));
  }

  async searchProducts(
    query: string,
    limit: number,
    categoryIds: number[] = [],
    minPrice?: number,
    maxPrice?: number,
  ): Promise<ProductSuggestionDto[]> {
    const normalizedQuery = query.trim();
    const normalizedCategoryIds = Array.from(
      new Set(
        categoryIds.filter(
          (categoryId) => Number.isInteger(categoryId) && categoryId > 0,
        ),
      ),
    );

    if (normalizedQuery.length === 0 && normalizedCategoryIds.length === 0) {
      return [];
    }

    const terms = normalizedQuery
      .toLowerCase()
      .split(/\s+/)
      .map((term) => term.trim())
      .filter((term) => term.length > 0);

    const idsQuery = this.repo
      .createQueryBuilder('p')
      .select('p.product_id', 'id')
      .distinct(true)
      .leftJoin('p.offers', 'offer', 'offer.status = :status', {
        status: 'open',
      })
      .leftJoin('p.productCategories', 'phc')
      .leftJoin('phc.category', 'category')
      .where('p.is_available = :avail', { avail: true })
      .andWhere('offer.offer_id IS NOT NULL');

    terms.forEach((term, index) => {
      const key = `term${index}`;
      idsQuery.andWhere(
        new Brackets((qb) => {
          qb.where(`LOWER(p.name) LIKE :${key}`, { [key]: `%${term}%` })
            .orWhere(`LOWER(COALESCE(p.description, '')) LIKE :${key}`, {
              [key]: `%${term}%`,
            })
            .orWhere(`LOWER(category.label) LIKE :${key}`, {
              [key]: `%${term}%`,
            });
        }),
      );
    });

    if (normalizedCategoryIds.length > 0) {
      idsQuery.andWhere('category.category_id IN (:...categoryIds)', {
        categoryIds: normalizedCategoryIds,
      });
    }

    if (minPrice != null) {
      idsQuery.andWhere('p.price >= :minPrice', { minPrice });
    }

    if (maxPrice != null) {
      idsQuery.andWhere('p.price <= :maxPrice', { maxPrice });
    }

    idsQuery.orderBy('RAND()');

    const rawIds = await idsQuery.limit(limit).getRawMany<{ id: number }>();
    const ids = rawIds.map((row) => row.id);

    if (ids.length === 0) {
      return [];
    }

    const products = await this.loadProductsForListing(ids);
    const order = new Map<number, number>(ids.map((id, index) => [id, index]));
    products.sort(
      (a, b) => order.get(a.product_id)! - order.get(b.product_id)!,
    );

    return products.map((product) => this.toSuggestionDto(product));
  }

  async getOfferDetail(offerId: number): Promise<ProductDetailDto> {
    const offerRepo = this.repo.manager.getRepository(Offer);
    const reservationRepo = this.repo.manager.getRepository(Reservation);
    const reviewRepo = this.repo.manager.getRepository(Review);

    const offer = await offerRepo
      .createQueryBuilder('offer')
      .leftJoinAndSelect('offer.product', 'product')
      .leftJoinAndSelect('offer.owner', 'owner')
      .leftJoinAndSelect('product.images', 'img')
      .leftJoinAndSelect('product.productCategories', 'phc')
      .leftJoinAndSelect('phc.category', 'category')
      .leftJoinAndSelect('product.unavailabilities', 'unavailability')
      .where('offer.offer_id = :offerId', { offerId })
      .getOne();

    if (!offer?.product || !offer.owner) {
      throw new NotFoundException('Annonce introuvable');
    }

    const product = offer.product;
    const owner = offer.owner;

    const rentalCount = await reservationRepo
      .createQueryBuilder('reservation')
      .leftJoin('reservation.offer', 'reservationOffer')
      .leftJoin('reservationOffer.product', 'reservationProduct')
      .where('reservationProduct.product_id = :productId', {
        productId: product.product_id,
      })
      .getCount();

    const reviewStats = await reviewRepo
      .createQueryBuilder('review')
      .leftJoin('review.reservation', 'reservation')
      .leftJoin('reservation.offer', 'reservationOffer')
      .leftJoin('reservationOffer.owner', 'reviewedOwner')
      .select('COUNT(review.review_id)', 'count')
      .addSelect('AVG(review.rating)', 'average')
      .where('reviewedOwner.user_id = :ownerId', { ownerId: owner.user_id })
      .getRawOne<{ count?: string; average?: string | null }>();

    const ownerOffersCount = await offerRepo
      .createQueryBuilder('ownerOffer')
      .leftJoin('ownerOffer.owner', 'offerOwner')
      .where('offerOwner.user_id = :ownerId', { ownerId: owner.user_id })
      .getCount();

    const otherOffers = await this.getOwnerOtherOffers(
      owner.user_id,
      offer.offer_id,
      4,
    );

    const activeReservations = await reservationRepo
      .createQueryBuilder('reservation')
      .leftJoin('reservation.offer', 'reservationOffer')
      .leftJoin('reservationOffer.product', 'reservationProduct')
      .where('reservationProduct.product_id = :productId', {
        productId: product.product_id,
      })
      .andWhere('reservation.status NOT IN (:...ignoredStatuses)', {
        ignoredStatuses: ['cancelled', 'canceled', 'rejected', 'refused'],
      })
      .getMany();

    const categories = Array.from(
      new Map(
        (product.productCategories ?? [])
          .map((relation) => relation.category)
          .filter((category): category is Category => category != null)
          .map((category) => [
            category.category_id,
            {
              category_id: category.category_id,
              label: category.label,
              parent_id: category.parent_id ?? 0,
            },
          ]),
      ).values(),
    );

    const images = (product.images ?? [])
      .slice()
      .sort((a, b) => (a.position_image ?? 0) - (b.position_image ?? 0))
      .map((image) => ({
        image_id: image.image_id,
        product_id: product.product_id,
        url: image.uri,
        position_image: image.position_image ?? 0,
        created_at: image.created_at,
      }));

    const unavailabilities = [
      ...(product.unavailabilities ?? []).map((entry) => ({
        unavailability_id: entry.unavailability_id,
        product_id: product.product_id,
        start_date_time: entry.start_date_time,
        end_date_time: entry.end_date_time,
      })),
      ...activeReservations.map((reservation) => ({
        unavailability_id: -reservation.reservation_id,
        product_id: product.product_id,
        start_date_time: reservation.start_date,
        end_date_time: reservation.end_date,
      })),
    ].sort((a, b) => a.start_date_time.getTime() - b.start_date_time.getTime());

    return {
      offer: {
        offer_id: offer.offer_id,
        product_id: product.product_id,
        user_id: owner.user_id,
        status: offer.status,
        amount: offer.amount,
        created_at: offer.created_at,
      },
      product: this.toProductDto(product),
      owner: this.toOwnerDto(owner),
      images,
      categories,
      unavailabilities,
      rental_count: rentalCount,
      owner_reviews_count: parseInt(reviewStats?.count ?? '0', 10) || 0,
      owner_rating_average: Number(reviewStats?.average ?? 0) || 0,
      owner_offers_count: ownerOffersCount,
      other_offers: otherOffers,
    };
  }

  private async loadProductsForListing(ids: number[]): Promise<Product[]> {
    if (ids.length === 0) {
      return [];
    }

    return this.repo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.images', 'img')
      .leftJoinAndSelect('p.offers', 'offer', 'offer.status = :status', {
        status: 'open',
      })
      .leftJoinAndSelect('offer.owner', 'offerOwner')
      .leftJoinAndSelect('p.productCategories', 'phc')
      .leftJoinAndSelect('phc.category', 'category')
      .where('p.product_id IN (:...ids)', { ids })
      .getMany();
  }

  private async getOwnerOtherOffers(
    ownerId: number,
    excludeOfferId: number,
    limit: number,
  ): Promise<ProductSuggestionDto[]> {
    const rawIds = await this.repo
      .createQueryBuilder('p')
      .select('p.product_id', 'id')
      .distinct(true)
      .leftJoin('p.offers', 'offer', 'offer.status = :status', {
        status: 'open',
      })
      .leftJoin('offer.owner', 'offerOwner')
      .where('p.is_available = :avail', { avail: true })
      .andWhere('offer.offer_id IS NOT NULL')
      .andWhere('offerOwner.user_id = :ownerId', { ownerId })
      .andWhere('offer.offer_id != :excludeOfferId', { excludeOfferId })
      .orderBy('RAND()')
      .limit(limit)
      .getRawMany<{ id: number }>();

    const ids = rawIds.map((row) => row.id);
    if (ids.length === 0) {
      return [];
    }

    const products = await this.loadProductsForListing(ids);
    const order = new Map<number, number>(ids.map((id, index) => [id, index]));
    products.sort(
      (a, b) => order.get(a.product_id)! - order.get(b.product_id)!,
    );

    return products.map((product) => this.toSuggestionDto(product));
  }

  private toProductDto(product: Product): ProductDto {
    const categoryIds = Array.from(
      new Set(
        (product.productCategories ?? [])
          .map((relation) => relation.category?.category_id)
          .filter(
            (categoryId): categoryId is number =>
              typeof categoryId === 'number',
          ),
      ),
    );

    return {
      product_id: product.product_id,
      name: product.name,
      description: product.description ?? null,
      category_ids: categoryIds,
      price: product.price ?? null,
      price_3_days: product.price_3_days ?? null,
      price_7_days: product.price_7_days ?? null,
      price_estimate: product.price_estimate ?? null,
      state: product.state,
      longitude: product.longitude ?? null,
      latitude: product.latitude ?? null,
      city: product.city,
      postal_code: product.postal_code,
      is_available: product.is_available,
      created_at: product.created_at,
      updated_at: product.updated_at,
    };
  }

  private toOwnerDto(user: User): ProductOwnerDto {
    return {
      user_id: user.user_id,
      first_name: user.first_name ?? null,
      last_name: user.last_name ?? null,
      email: user.email ?? null,
      login: user.login ?? null,
      phone_number: user.phone_number ?? null,
      longitude: user.longitude ?? null,
      latitude: user.latitude ?? null,
      postal_code: user.postal_code ?? null,
      city: user.city ?? null,
      is_verified: user.is_verified,
      created_at: user.created_at,
      updated_at: user.updated_at,
    };
  }

  private toSuggestionDto(product: Product): ProductSuggestionDto {
    const firstImage = (product.images ?? [])
      .slice()
      .sort((a, b) => (a.position_image ?? 0) - (b.position_image ?? 0))[0];

    const openOffer = (product.offers ?? [])
      .filter((offer) => offer.status === 'open')
      .slice()
      .sort((a, b) => b.created_at.getTime() - a.created_at.getTime())[0];

    const productDto = this.toProductDto(product);

    return {
      ...productDto,
      image_uri: firstImage?.uri ?? null,
      offer_id: openOffer?.offer_id ?? null,
      offer_user_id: openOffer?.owner?.user_id ?? null,
      offer_status: openOffer?.status ?? null,
      offer_amount: openOffer?.amount ?? null,
      offer_created_at: openOffer?.created_at ?? null,
    };
  }

  async createOffer(
    ownerUserId: number,
    dto: CreateOfferDto,
  ): Promise<CreatedOfferDto> {
    return this.repo.manager.transaction(async (manager) => {
      const userRepo = manager.getRepository(User);
      const productRepo = manager.getRepository(Product);
      const offerRepo = manager.getRepository(Offer);
      const imageRepo = manager.getRepository(Image);
      const categoryRepo = manager.getRepository(Category);
      const phcRepo = manager.getRepository(ProductHasCategory);
      const unavailabilityRepo = manager.getRepository(ProductUnavailability);

      const owner = await userRepo.findOne({ where: { user_id: ownerUserId } });
      if (!owner) {
        throw new NotFoundException('Utilisateur introuvable');
      }

      const normalizedCity = (dto.city ?? '').trim();
      const normalizedPostal = sanitizePostalCode(dto.postalCode);

      const product = await productRepo.save(
        productRepo.create({
          name: dto.title.trim(),
          description: dto.description?.trim() ?? '',
          price: dto.pricePerDay,
          price_3_days: dto.price3Days ?? undefined,
          price_7_days: dto.price7Days ?? undefined,
          price_estimate: dto.priceEstimate ?? undefined,
          state: dto.state.trim(),
          city:
            normalizedCity.length > 0 ? normalizedCity : owner.city || 'Ville',
          postal_code:
            normalizedPostal.length > 0
              ? normalizedPostal
              : sanitizePostalCode(owner.postal_code),
          latitude: dto.latitude ?? undefined,
          longitude: dto.longitude ?? undefined,
          is_available: true,
          owner,
        }),
      );

      const imageUris = (dto.photoUris ?? [])
        .map((u) => u.trim())
        .filter((u) => u.length > 0)
        .slice(0, 5);

      for (let i = 0; i < imageUris.length; i += 1) {
        await imageRepo.save(
          imageRepo.create({
            product,
            uri: imageUris[i],
            position_image: i,
          }),
        );
      }

      const uniqueCategoryIds = Array.from(new Set(dto.categoryIds ?? []));
      if (uniqueCategoryIds.length > 0) {
        const cats = await categoryRepo.findBy({
          category_id: In(uniqueCategoryIds),
        });

        if (cats.length !== uniqueCategoryIds.length) {
          throw new BadRequestException(
            'Une ou plusieurs categories sont invalides',
          );
        }

        const rootParentIds = new Set(
          cats.map((cat) =>
            cat.parent_id === 0 ? cat.category_id : cat.parent_id,
          ),
        );

        if (rootParentIds.size > 1) {
          throw new BadRequestException(
            'Les categories doivent appartenir a une seule categorie parente',
          );
        }

        const parentCategories = cats.filter((cat) => cat.parent_id === 0);
        if (parentCategories.length > 1) {
          throw new BadRequestException(
            'Une seule categorie parente peut etre selectionnee',
          );
        }

        const rootParentId = Array.from(rootParentIds)[0];
        const normalizedIds = new Set<number>([rootParentId]);

        for (const cat of cats) {
          if (cat.parent_id !== 0) {
            normalizedIds.add(cat.category_id);
          }
        }

        const normalizedCategories = await categoryRepo.findBy({
          category_id: In(Array.from(normalizedIds)),
        });

        for (const cat of normalizedCategories) {
          await phcRepo.save(
            phcRepo.create({
              product,
              category: cat,
            }),
          );
        }
      }

      for (const item of dto.unavailableDates ?? []) {
        const parsed = new Date(item.isoDate);
        if (Number.isNaN(parsed.getTime())) continue;

        const start = new Date(
          Date.UTC(
            parsed.getUTCFullYear(),
            parsed.getUTCMonth(),
            parsed.getUTCDate(),
            0,
            0,
            0,
          ),
        );
        const end = new Date(
          Date.UTC(
            parsed.getUTCFullYear(),
            parsed.getUTCMonth(),
            parsed.getUTCDate(),
            23,
            59,
            59,
          ),
        );

        await unavailabilityRepo.save(
          unavailabilityRepo.create({
            product,
            start_date_time: start,
            end_date_time: end,
          }),
        );
      }

      const offer = await offerRepo.save(
        offerRepo.create({
          owner,
          product,
          amount: dto.pricePerDay,
          status: 'open',
        }),
      );

      return {
        product_id: product.product_id,
        offer_id: offer.offer_id,
      };
    });
  }

  async createReservation(
    renterUserId: number,
    offerId: number,
    dto: CreateReservationDto,
  ): Promise<CreatedReservationDto> {
    return this.repo.manager.transaction(async (manager) => {
      const prepared = await this.prepareReservationCreation(
        manager,
        renterUserId,
        offerId,
        dto,
      );

      return this.persistReservation(
        manager,
        renterUserId,
        prepared,
        'pending',
      );
    });
  }

  async checkoutReservation(
    renterUserId: number,
    offerId: number,
    dto: CheckoutReservationDto,
  ): Promise<ReservationCheckoutDto> {
    const created = await this.repo.manager.transaction(async (manager) => {
      const prepared = await this.prepareReservationCreation(
        manager,
        renterUserId,
        offerId,
        dto,
      );

      const reservation = await this.persistReservation(
        manager,
        renterUserId,
        prepared,
        'payment_pending',
      );

      return {
        ...reservation,
        finalPrice: prepared.finalPrice,
      };
    });

    try {
      const payment = await this.paymentsService.chargeDemoPayment(
        created.finalPrice,
        created.reservation_id,
        dto.paymentScenario,
      );

      await this.updateReservationLifecycleStatus(
        created.reservation_id,
        'pending',
      );

      return {
        reservation_id: created.reservation_id,
        conversation_id: created.conversation_id,
        payment_provider: payment.provider,
        payment_status: payment.status,
        payment_reference: payment.reference,
        payment_card_label: payment.cardLabel,
        payment_card_preview: payment.cardNumberPreview,
      };
    } catch (error) {
      await this.updateReservationLifecycleStatus(
        created.reservation_id,
        'cancelled',
      );
      this.paymentsService.failUnexpectedPaymentError(error);
    }
  }

  async updateReservationStatus(
    actorUserId: number,
    reservationId: number,
    status: 'accepted' | 'refused',
  ): Promise<UpdatedReservationStatusDto> {
    const reservationRepo = this.repo.manager.getRepository(Reservation);

    const reservation = await reservationRepo.findOne({
      where: { reservation_id: reservationId },
      relations: ['offer', 'offer.owner', 'renter'],
    });

    if (!reservation?.offer?.owner || !reservation.renter) {
      throw new NotFoundException('Réservation introuvable');
    }

    if (reservation.offer.owner.user_id !== actorUserId) {
      throw new ForbiddenException(
        'Seul le propriétaire peut répondre à cette demande',
      );
    }

    if (reservation.status !== 'pending') {
      throw new BadRequestException(
        "Cette demande n'est plus en attente de validation",
      );
    }

    reservation.status = status;
    await reservationRepo.save(reservation);

    return {
      reservation_id: reservation.reservation_id,
      status: reservation.status,
    };
  }

  private computeReservationPrice(product: Product, days: number): number {
    const safeDays = Math.max(1, days);
    const dailyPrice = Number(product.price ?? 0);
    const price3Days = Number(product.price_3_days ?? 0);
    const price7Days = Number(product.price_7_days ?? 0);

    let dailyRate = dailyPrice;
    if (safeDays >= 7 && price7Days > 0) {
      dailyRate = price7Days / 7;
    } else if (safeDays >= 3 && price3Days > 0) {
      dailyRate = price3Days / 3;
    }

    return Math.round(dailyRate * safeDays * 100) / 100;
  }

  private normalizeDateOnly(value: Date): Date {
    return new Date(
      Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()),
    );
  }

  private normalizeStartOfDay(rawIso: string): Date | null {
    const parsed = new Date(rawIso);
    if (Number.isNaN(parsed.getTime())) {
      return null;
    }

    return new Date(
      Date.UTC(
        parsed.getUTCFullYear(),
        parsed.getUTCMonth(),
        parsed.getUTCDate(),
        0,
        0,
        0,
        0,
      ),
    );
  }

  private normalizeEndOfDay(rawIso: string): Date | null {
    const parsed = new Date(rawIso);
    if (Number.isNaN(parsed.getTime())) {
      return null;
    }

    return new Date(
      Date.UTC(
        parsed.getUTCFullYear(),
        parsed.getUTCMonth(),
        parsed.getUTCDate(),
        23,
        59,
        59,
        999,
      ),
    );
  }

  private async prepareReservationCreation(
    manager: EntityManager,
    renterUserId: number,
    offerId: number,
    dto: CreateReservationDto,
  ): Promise<{
    renter: User;
    offer: Offer;
    startDate: Date;
    endDate: Date;
    finalPrice: number;
  }> {
    const userRepo = manager.getRepository(User);
    const offerRepo = manager.getRepository(Offer);
    const reservationRepo = manager.getRepository(Reservation);
    const unavailabilityRepo = manager.getRepository(ProductUnavailability);

    const [renter, offer] = await Promise.all([
      userRepo.findOne({ where: { user_id: renterUserId } }),
      offerRepo.findOne({
        where: { offer_id: offerId },
        relations: ['owner', 'product'],
      }),
    ]);

    if (!renter) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    if (!offer?.owner || !offer.product) {
      throw new NotFoundException('Annonce introuvable');
    }

    if (offer.owner.user_id === renterUserId) {
      throw new BadRequestException(
        'Vous ne pouvez pas louer votre propre produit',
      );
    }

    if (offer.status !== 'open') {
      throw new BadRequestException("Cette annonce n'est plus disponible");
    }

    if (!offer.product.is_available) {
      throw new BadRequestException("Ce produit n'est pas disponible");
    }

    const startDate = this.normalizeStartOfDay(dto.startDate);
    const endDate = this.normalizeEndOfDay(dto.endDate);

    if (!startDate || !endDate) {
      throw new BadRequestException('Dates de réservation invalides');
    }

    if (endDate.getTime() < startDate.getTime()) {
      throw new BadRequestException(
        'La date de fin doit être postérieure ou égale à la date de début',
      );
    }

    const today = this.normalizeDateOnly(new Date());
    if (startDate.getTime() < today.getTime()) {
      throw new BadRequestException('Impossible de réserver une date passée');
    }

    const conflictingUnavailability = await unavailabilityRepo
      .createQueryBuilder('unavailability')
      .leftJoin('unavailability.product', 'product')
      .where('product.product_id = :productId', {
        productId: offer.product.product_id,
      })
      .andWhere('unavailability.start_date_time <= :endDate', { endDate })
      .andWhere('unavailability.end_date_time >= :startDate', { startDate })
      .getOne();

    if (conflictingUnavailability) {
      throw new BadRequestException(
        'Ce produit est indisponible sur une partie de la période sélectionnée',
      );
    }

    const conflictingReservation = await reservationRepo
      .createQueryBuilder('reservation')
      .leftJoin('reservation.offer', 'reservationOffer')
      .leftJoin('reservationOffer.product', 'reservationProduct')
      .where('reservationProduct.product_id = :productId', {
        productId: offer.product.product_id,
      })
      .andWhere('reservation.start_date <= :endDate', { endDate })
      .andWhere('reservation.end_date >= :startDate', { startDate })
      .andWhere('reservation.status NOT IN (:...ignoredStatuses)', {
        ignoredStatuses: ['cancelled', 'canceled', 'rejected', 'refused'],
      })
      .getOne();

    if (conflictingReservation) {
      throw new BadRequestException(
        'Ce produit est déjà réservé sur une partie de la période sélectionnée',
      );
    }

    const days =
      Math.floor(
        (this.normalizeDateOnly(endDate).getTime() -
          this.normalizeDateOnly(startDate).getTime()) /
          86400000,
      ) + 1;

    return {
      renter,
      offer,
      startDate,
      endDate,
      finalPrice: this.computeReservationPrice(offer.product, days),
    };
  }

  private async persistReservation(
    manager: EntityManager,
    renterUserId: number,
    prepared: {
      renter: User;
      offer: Offer;
      startDate: Date;
      endDate: Date;
      finalPrice: number;
    },
    status: string,
  ): Promise<CreatedReservationDto> {
    const reservationRepo = manager.getRepository(Reservation);
    const conversationRepo = manager.getRepository(Conversation);

    const reservation = await reservationRepo.save(
      reservationRepo.create({
        offer: prepared.offer,
        renter: prepared.renter,
        start_date: prepared.startDate,
        end_date: prepared.endDate,
        status,
        final_price: prepared.finalPrice,
      }),
    );

    const existingConversation = await conversationRepo.findOne({
      where: [
        {
          renter: { user_id: renterUserId },
          owner: { user_id: prepared.offer.owner.user_id },
        },
        {
          renter: { user_id: prepared.offer.owner.user_id },
          owner: { user_id: renterUserId },
        },
      ],
      relations: ['renter', 'owner', 'reservation'],
      order: { conversation_id: 'DESC' },
    });

    const conversation = await conversationRepo.save(
      existingConversation != null
        ? {
            ...existingConversation,
            renter: prepared.renter,
            owner: prepared.offer.owner,
            reservation,
          }
        : conversationRepo.create({
            renter: prepared.renter,
            owner: prepared.offer.owner,
            reservation,
          }),
    );

    return {
      reservation_id: reservation.reservation_id,
      conversation_id: conversation.conversation_id,
    };
  }

  private async updateReservationLifecycleStatus(
    reservationId: number,
    status: string,
  ): Promise<void> {
    const reservationRepo = this.repo.manager.getRepository(Reservation);

    await reservationRepo.update(
      { reservation_id: reservationId },
      { status, updated_at: new Date() },
    );
  }
}
