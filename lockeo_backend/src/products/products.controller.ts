import {
  Body,
  BadRequestException,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ProductsService } from './products.service';
import { ProductDetailDto, ProductSuggestionDto } from './products.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateOfferDto } from './dto/create-offer.dto';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { UpdateReservationStatusDto } from './dto/update-reservation-status.dto';
import { CheckoutReservationDto } from './dto/checkout-reservation.dto';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { extname } from 'path';
import { MessagingGateway } from '../messaging/messaging.gateway';
import { ensureProductUploadsDir } from '../uploads/uploads-path';

type UploadedImageFile = {
  filename: string;
  originalname?: string;
};

type DiskStorageFactory = (options: {
  destination: string;
  filename: (
    req: Request,
    file: { originalname?: string },
    cb: (error: Error | null, filename: string) => void,
  ) => void;
}) => unknown;

// eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-unsafe-assignment
const { diskStorage }: { diskStorage: DiskStorageFactory } = require('multer');

const productUploadsDir = ensureProductUploadsDir();
const allowedImageExtensions = new Set([
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
]);

function slugifyFilename(name: string): string {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .toLowerCase();
}

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('products')
@Controller('products')
export class ProductsController {
  constructor(
    private readonly products: ProductsService,
    private readonly messagingGateway: MessagingGateway,
  ) {}

  @Get('suggestions')
  async suggestions(
    @Query('limit') limit = '4',
  ): Promise<ProductSuggestionDto[]> {
    const take = Math.max(1, Math.min(parseInt(limit || '4', 10) || 4, 20));
    return this.products.getSuggestions(take);
  }

  @Get('search')
  @ApiOperation({
    summary: "Rechercher des annonces par nom d'objet ou mot-clé",
  })
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
  async getOfferDetail(
    @Param('offerId') offerId: string,
  ): Promise<ProductDetailDto> {
    const parsedOfferId = parseInt(offerId, 10);
    return this.products.getOfferDetail(parsedOfferId);
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Post('uploads')
  @UseInterceptors(
    FilesInterceptor('files', 5, {
      storage: diskStorage({
        destination: productUploadsDir,
        filename: (
          _req: Request,
          file: { originalname?: string },
          cb: (error: Error | null, filename: string) => void,
        ) => {
          const originalName = file.originalname ?? 'image.jpg';
          const extension = extname(originalName).toLowerCase();
          const baseName = originalName.slice(
            0,
            Math.max(0, originalName.length - extension.length),
          );
          const safeBaseName = slugifyFilename(baseName) || 'image';
          const uniqueSuffix =
            Date.now().toString(36) + '-' + Math.round(Math.random() * 1e9);

          cb(null, `${safeBaseName}-${uniqueSuffix}${extension || '.jpg'}`);
        },
      }),
      fileFilter: (
        _req: Request,
        file: { originalname?: string },
        cb: (error: Error | null, acceptFile: boolean) => void,
      ) => {
        const extension = extname(file.originalname ?? '').toLowerCase();
        if (!allowedImageExtensions.has(extension)) {
          cb(
            new BadRequestException(
              'Seuls les fichiers jpg, jpeg, png, webp et gif sont acceptes',
            ) as Error,
            false,
          );
          return;
        }

        cb(null, true);
      },
      limits: {
        files: 5,
        fileSize: 10 * 1024 * 1024,
      },
    }),
  )
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: {
          type: 'array',
          items: { type: 'string', format: 'binary' },
        },
      },
    },
  })
  @ApiOperation({
    summary: 'Uploader des images produit avant la creation d une annonce',
  })
  uploadProductImages(@UploadedFiles() files: UploadedImageFile[] = []): {
    urls: string[];
  } {
    if (files.length === 0) {
      throw new BadRequestException('Aucune image recue');
    }

    return {
      urls: files.map((file) => `uploads/products/${file.filename}`),
    };
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Post('create-offer')
  @ApiOperation({
    summary: 'Créer une annonce produit + offre depuis le parcours de création',
  })
  async createOffer(@Req() req: RequestWithUser, @Body() body: CreateOfferDto) {
    return this.products.createOffer(req.user.userId, body);
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Post('offers/:offerId/reservations')
  @ApiOperation({ summary: 'Créer une demande de location pour une annonce' })
  async createReservation(
    @Req() req: RequestWithUser,
    @Param('offerId') offerId: string,
    @Body() body: CreateReservationDto,
  ) {
    const parsedOfferId = parseInt(offerId, 10);
    return this.products.createReservation(
      req.user.userId,
      parsedOfferId,
      body,
    );
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Post('offers/:offerId/reservations/checkout')
  @ApiOperation({
    summary:
      'Effectuer un paiement de demonstration puis creer la demande de location',
  })
  async checkoutReservation(
    @Req() req: RequestWithUser,
    @Param('offerId') offerId: string,
    @Body() body: CheckoutReservationDto,
  ) {
    const parsedOfferId = parseInt(offerId, 10);
    return this.products.checkoutReservation(
      req.user.userId,
      parsedOfferId,
      body,
    );
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Patch('reservations/:reservationId/status')
  @ApiOperation({
    summary: "Mettre à jour le statut d'une demande de location",
  })
  async updateReservationStatus(
    @Req() req: RequestWithUser,
    @Param('reservationId') reservationId: string,
    @Body() body: UpdateReservationStatusDto,
  ) {
    const parsedReservationId = parseInt(reservationId, 10);
    const result = await this.products.updateReservationStatus(
      req.user.userId,
      parsedReservationId,
      body.status,
    );
    if (result.realtime_notification != null) {
      this.messagingGateway.emitNotificationToUser(
        result.realtime_notification,
      );
    }
    return result;
  }
}
