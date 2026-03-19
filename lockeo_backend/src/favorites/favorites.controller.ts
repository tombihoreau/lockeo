import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FavoritesService, FavoriteProductDto } from './favorites.service';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/jwt.strategy';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favorites: FavoritesService) {}

  @Get('recent')
  @UseGuards(JwtAuthGuard)
  async recent(
    @Req() req: RequestWithUser,
    @Query('limit') limit = '4',
  ): Promise<FavoriteProductDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '4', 10) || 4, 20));
    return this.favorites.getRecentFavorites(req.user.userId, take);
  }
}
