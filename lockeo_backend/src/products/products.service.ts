import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';

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
@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product) private readonly repo: Repository<Product>,
  ) {}

  async getSuggestions(limit: number): Promise<ProductSuggestionDto[]> {
    // Étape 1: tirer au sort des IDs de produits (sans JOIN) pour éviter le
    // problème LIMIT + LEFT JOIN (qui peut réduire le nombre d'éléments après déduplication)
    const rawIds = await this.repo
      .createQueryBuilder('p')
      .select('p.product_id', 'id')
      .where('p.is_available = :avail', { avail: true })
      .orderBy('RAND()')
      .limit(limit)
      .getRawMany<{ id: number }>();

    const ids = rawIds.map((r) => r.id);
    if (ids.length === 0) return [];

    // Étape 2: charger les produits avec leurs images pour ces IDs
    const products = await this.repo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.images', 'img')
      .where('p.product_id IN (:...ids)', { ids })
      .getMany();

    // Conserver l'ordre aléatoire tiré à l'étape 1
    const order = new Map<number, number>(ids.map((id, i) => [id, i]));
    products.sort(
      (a, b) => order.get(a.product_id)! - order.get(b.product_id)!,
    );

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
          ? ([...p.images].sort(
              (a, b) => (a.position_image ?? 0) - (b.position_image ?? 0),
            )[0]?.uri ?? null)
          : null,
    }));
  }
}
