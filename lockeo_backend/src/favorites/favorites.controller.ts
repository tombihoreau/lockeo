import {
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  FavoritesService,
  FavoriteMutationDto,
  FavoriteProductDto,
} from './favorites.service';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/jwt.strategy';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favorites: FavoritesService) {}

  @Get('product-ids')
  @UseGuards(JwtAuthGuard)
  async productIds(@Req() req: RequestWithUser): Promise<number[]> {
    return this.favorites.getFavoriteProductIds(req.user.userId);
  }

  @Get('recent')
  @UseGuards(JwtAuthGuard)
  async recent(
    @Req() req: RequestWithUser,
    @Query('limit') limit = '4',
  ): Promise<FavoriteProductDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '4', 10) || 4, 20));
    return this.favorites.getRecentFavorites(req.user.userId, take);
  }

  @Post(':productId')
  @UseGuards(JwtAuthGuard)
  async add(
    @Req() req: RequestWithUser,
    @Param('productId', ParseIntPipe) productId: number,
  ): Promise<FavoriteMutationDto> {
    return this.favorites.addFavorite(req.user.userId, productId);
  }

  @Delete(':productId')
  @UseGuards(JwtAuthGuard)
  async remove(
    @Req() req: RequestWithUser,
    @Param('productId', ParseIntPipe) productId: number,
  ): Promise<FavoriteMutationDto> {
    return this.favorites.removeFavorite(req.user.userId, productId);
  }
}
