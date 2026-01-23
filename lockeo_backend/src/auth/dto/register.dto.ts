import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({
    example: 'alice@lockeo.io',
    description: 'Adresse e-mail (unique).',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    minLength: 8,
    format: 'password',
    description:
      'Mot de passe (8+). Recommandé: 1 majuscule, 1 chiffre, 1 caractère spécial.',
  })
  @IsString()
  @MinLength(8)
  // Correspond à l’indication UI côté Flutter.
  // Au besoin on ajustera la regex selon votre politique exacte.
  @Matches(/^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$/u, {
    message:
      'Le mot de passe doit contenir au moins 1 majuscule, 1 chiffre et 1 caractère spécial.',
  })
  password: string;

  @ApiPropertyOptional({
    format: 'password',
    description:
      'Confirmation du mot de passe (optionnel côté API, recommandé côté front).',
  })
  @IsOptional()
  @IsString()
  @MinLength(8)
  passwordConfirm?: string;

  @ApiPropertyOptional({
    example: 'alice',
    description: "Login (unique). Si absent, on utilise l'email.",
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  login?: string;

  @ApiProperty({
    example: 'Alice',
    description: 'Prénom (obligatoire).',
  })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  firstName: string;

  @ApiProperty({
    example: 'Dupont',
    description: 'Nom (obligatoire).',
  })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  lastName: string;

  @ApiPropertyOptional({ example: '+33601020304' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phoneNumber?: string;
}
