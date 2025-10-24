import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'alice@lockeo.io' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 8, format: 'password' })
  @IsString()
  @MinLength(8)
  password: string;
}
