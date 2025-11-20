import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'alice@lockeo.io' })
  @IsEmail()
  email: string;

  @ApiProperty({ format: 'password' })
  @IsString()
  password: string;
}
