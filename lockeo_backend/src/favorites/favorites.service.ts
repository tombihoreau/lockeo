import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorite } from '../entities/favorite.entity';

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
  constructor(@InjectRepository(Favorite) private readonly repo: Repository<Favorite>) {}

  async getRecentFavorites(userId: number, limit: number): Promise<FavoriteProductDto[]> {
    const favorites = await this.repo.createQueryBuilder('f')
      .leftJoinAndSelect('f.product', 'p')
      .leftJoinAndSelect('p.images', 'img')
      .where('f.user = :userId', { userId })
      .orderBy('f.created_at', 'DESC')
      .limit(limit)
      .getMany();

    return favorites.map((f) => {
      const p = f.product;
      const imageUri = (p?.images && p.images.length > 0)
        ? [...p.images].sort((a, b) => (a.position_image ?? 0) - (b.position_image ?? 0))[0].uri
        : null;

      return {
        product_id: p.product_id,
        name: p.name,
        description: p.description ?? null,
        price: (p as any).price ?? null,
        price_estimate: (p as any).price_estimate ?? null,
        state: p.state,
        longitude: p.longitude ?? null,
        latitude: p.latitude ?? null,
        city: p.city,
        postal_code: p.postal_code,
        is_available: p.is_available,
        created_at: p.created_at,
        updated_at: p.updated_at,
        image_uri: imageUri,
        favorited_at: f.created_at,
      };
    });
  }
}
