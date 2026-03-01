import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { Image } from '../entities/image.entity';
import { User } from '../entities/user.entity';
import { Offer } from '../entities/offer.entity';
import { Category } from '../entities/category.entity';
import { ProductHasCategory } from '../entities/product-has-category.entity';
import { ProductUnavailability } from '../entities/product-unavailability.entity';
import { CreateOfferDto } from './dto/create-offer.dto';

export interface ProductSuggestionDto {
  product_id: number;
  name: string;
  description: string | null;
  price: string | number | null;
  price_estimate: string | number | null;
  state: string;
  longitude: number | null;
  latitude: number | null;
  city: string;
  postal_code: string;
  is_available: boolean;
  created_at: Date;
  updated_at: Date;
  image_uri?: string | null;
}

export interface CreatedOfferDto {
  product_id: number;
  offer_id: number;
}

@Injectable()
export class ProductsService {
  constructor(@InjectRepository(Product) private readonly repo: Repository<Product>) {}

  async getSuggestions(limit: number): Promise<ProductSuggestionDto[]> {
    const rawIds = await this.repo
      .createQueryBuilder('p')
      .select('p.product_id', 'id')
      .where('p.is_available = :avail', { avail: true })
      .orderBy('RAND()')
      .limit(limit)
      .getRawMany<{ id: number }>();

    const ids = rawIds.map((r) => r.id);
    if (ids.length === 0) return [];

    const products = await this.repo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.images', 'img')
      .where('p.product_id IN (:...ids)', { ids })
      .getMany();

    const order = new Map<number, number>(ids.map((id, i) => [id, i]));
    products.sort((a, b) => order.get(a.product_id)! - order.get(b.product_id)!);

    return products.map((p) => ({
      product_id: p.product_id,
      name: p.name,
      description: p.description ?? null,
      price: p.price ?? null,
      price_estimate: p.price_estimate ?? null,
      state: p.state,
      longitude: p.longitude ?? null,
      latitude: p.latitude ?? null,
      city: p.city,
      postal_code: p.postal_code,
      is_available: p.is_available,
      created_at: p.created_at,
      updated_at: p.updated_at,
      image_uri:
        p.images && p.images.length > 0
          ? [...p.images].sort((a, b) => (a.position_image ?? 0) - (b.position_image ?? 0))[0]
              .uri
          : null,
    }));
  }

  async createOffer(ownerUserId: number, dto: CreateOfferDto): Promise<CreatedOfferDto> {
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
      const normalizedPostal = (dto.postalCode ?? '').trim();

      const product = await productRepo.save(
        productRepo.create({
          name: dto.title.trim(),
          description: dto.description?.trim() ?? '',
          price: dto.pricePerDay,
          price_estimate: dto.priceEstimate ?? undefined,
          state: dto.state.trim(),
          city: normalizedCity.length > 0 ? normalizedCity : owner.city || 'Ville',
          postal_code:
            normalizedPostal.length > 0 ? normalizedPostal : owner.postal_code || '00000',
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
        const cats = await categoryRepo.findBy({ category_id: In(uniqueCategoryIds) });
        for (const cat of cats) {
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

        const start = new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate(), 0, 0, 0));
        const end = new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate(), 23, 59, 59));

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
}
