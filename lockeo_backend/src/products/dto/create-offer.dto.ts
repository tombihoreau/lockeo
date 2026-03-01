import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

class UnavailableDateDto {
  @IsString()
  isoDate: string;
}

export class CreateOfferDto {
  @IsString()
  @MaxLength(50)
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsString()
  @MaxLength(50)
  state: string;

  @IsNumber()
  @Min(0)
  pricePerDay: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  priceEstimate?: number;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  postalCode?: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsArray()
  categoryIds?: number[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(5)
  photoUris?: string[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UnavailableDateDto)
  unavailableDates?: UnavailableDateDto[];
}
