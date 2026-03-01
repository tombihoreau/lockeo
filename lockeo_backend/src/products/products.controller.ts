import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { ProductSuggestionDto } from './products.service';
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
