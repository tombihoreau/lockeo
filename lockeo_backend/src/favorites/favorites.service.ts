import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorite } from '../entities/favorite.entity';
import { Product } from '../entities/product.entity';

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
  favorited_at: Date;
}

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(Favorite) private readonly repo: Repository<Favorite>,
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
      favorited_at: favorite.created_at,
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
