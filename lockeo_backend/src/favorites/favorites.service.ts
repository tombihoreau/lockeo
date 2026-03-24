import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorite } from '../entities/favorite.entity';
import { Product } from '../entities/product.entity';
import { User } from '../entities/user.entity';

export interface FavoriteProductDto {
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
  is_favorite: boolean;
  favorited_at: Date;
}

export interface FavoriteMutationDto {
  product_id: number;
  is_favorite: boolean;
}

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(Favorite) private readonly repo: Repository<Favorite>,
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
  ) {}

  private toFavoriteProductDto(favorite: Favorite): FavoriteProductDto {
    const product = favorite.product as Product | null | undefined;
    if (!product) {
      throw new Error('Favorite product relation is missing');
    }

    const imageUri =
      product.images && product.images.length > 0
        ? ([...product.images].sort(
            (a, b) => (a.position_image ?? 0) - (b.position_image ?? 0),
          )[0]?.uri ?? null)
        : null;

    return {
      product_id: product.product_id,
      name: product.name,
      description: product.description ?? null,
      price: product.price ?? null,
      price_estimate: product.price_estimate ?? null,
      state: product.state,
      longitude: product.longitude ?? null,
      latitude: product.latitude ?? null,
      city: product.city,
      postal_code: product.postal_code,
      is_available: product.is_available,
      created_at: product.created_at,
      updated_at: product.updated_at,
      image_uri: imageUri,
      is_favorite: true,
      favorited_at: favorite.created_at,
    };
  }

  async getFavoriteProductIds(userId: number): Promise<number[]> {
    const rows = await this.repo
      .createQueryBuilder('favorite')
      .leftJoin('favorite.product', 'product')
      .select('product.product_id', 'product_id')
      .where('favorite.user = :userId', { userId })
      .orderBy('favorite.created_at', 'DESC')
      .getRawMany<{ product_id: number | string }>();

    return rows
      .map((row) =>
        typeof row.product_id === 'number'
          ? row.product_id
          : parseInt(row.product_id, 10),
      )
      .filter((productId) => Number.isInteger(productId) && productId > 0);
  }

  async addFavorite(
    userId: number,
    productId: number,
  ): Promise<FavoriteMutationDto> {
    const product = await this.productRepo.findOne({
      where: { product_id: productId },
      select: { product_id: true },
    });
    if (!product) {
      throw new NotFoundException('Produit introuvable');
    }

    const existing = await this.repo
      .createQueryBuilder('favorite')
      .leftJoin('favorite.product', 'product')
      .where('favorite.user = :userId', { userId })
      .andWhere('product.product_id = :productId', { productId })
      .getOne();

    if (!existing) {
      await this.repo.save(
        this.repo.create({
          user: { user_id: userId } as User,
          product: { product_id: productId } as Product,
        }),
      );
    }

    return {
      product_id: productId,
      is_favorite: true,
    };
  }

  async removeFavorite(
    userId: number,
    productId: number,
  ): Promise<FavoriteMutationDto> {
    await this.repo
      .createQueryBuilder()
      .delete()
      .from(Favorite)
      .where('userUserId = :userId', { userId })
      .andWhere('productProductId = :productId', { productId })
      .execute();

    return {
      product_id: productId,
      is_favorite: false,
    };
  }

  async getRecentFavorites(
    userId: number,
    limit: number,
  ): Promise<FavoriteProductDto[]> {
    const favorites = await this.repo
      .createQueryBuilder('f')
      .leftJoinAndSelect('f.product', 'p')
      .leftJoinAndSelect('p.images', 'img')
      .where('f.user = :userId', { userId })
      .orderBy('f.created_at', 'DESC')
      .limit(limit)
      .getMany();

    return favorites.map((favorite) => this.toFavoriteProductDto(favorite));
  }
}
