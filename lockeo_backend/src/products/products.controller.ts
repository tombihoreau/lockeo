import { Body, Controller, Get, Param, Post, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { ProductDetailDto, ProductSuggestionDto } from './products.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateOfferDto } from './dto/create-offer.dto';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/jwt.strategy';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('products')
@Controller('products')
export class ProductsController {
  constructor(private readonly products: ProductsService) {}

  @Get('suggestions')
  async suggestions(@Query('limit') limit = '4'): Promise<ProductSuggestionDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '4', 10) || 4, 20));
    return this.products.getSuggestions(take);
  }

  @Get('search')
  @ApiOperation({ summary: "Rechercher des annonces par nom d'objet ou mot-clé" })
  async search(
    @Query('q') query = '',
    @Query('limit') limit = '24',
    @Query('categoryIds') categoryIds = '',
    @Query('minPrice') minPrice?: string,
    @Query('maxPrice') maxPrice?: string,
  ): Promise<ProductSuggestionDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '24', 10) || 24, 50));
    const parsedCategoryIds = categoryIds
      .split(',')
      .map((value) => parseInt(value.trim(), 10))
      .filter((value) => Number.isInteger(value) && value > 0);

    const parsedMinPrice = minPrice != null ? Number(minPrice) : undefined;
    const parsedMaxPrice = maxPrice != null ? Number(maxPrice) : undefined;

    return this.products.searchProducts(
      query,
      take,
      parsedCategoryIds,
      Number.isFinite(parsedMinPrice) ? parsedMinPrice : undefined,
      Number.isFinite(parsedMaxPrice) ? parsedMaxPrice : undefined,
    );
  }

  @Get('offers/:offerId')
  @ApiOperation({ summary: "Récupérer le détail d'une annonce" })
  async getOfferDetail(@Param('offerId') offerId: string): Promise<ProductDetailDto> {
    const parsedOfferId = parseInt(offerId, 10);
    return this.products.getOfferDetail(parsedOfferId);
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Post('create-offer')
  @ApiOperation({ summary: "Créer une annonce produit + offre depuis le parcours de création" })
  async createOffer(
    @Req() req: RequestWithUser,
    @Body() body: CreateOfferDto,
  ) {
    return this.products.createOffer(req.user.userId, body);
  }
}
