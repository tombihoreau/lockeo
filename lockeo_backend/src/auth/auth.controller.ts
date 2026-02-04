import { BadRequestException, Body, Controller,Get, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UsersService } from '../users/users.service';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { Request } from 'express';
import type { AuthenticatedUser } from './jwt.strategy';

interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private users: UsersService, private auth: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Créer un compte (hash bcrypt)' })
  @ApiCreatedResponse({ type: AuthResponseDto })
  async register(@Body() dto: RegisterDto): Promise<AuthResponseDto> {
    if (dto.passwordConfirm != null && dto.passwordConfirm !== dto.password) {
      throw new BadRequestException('Passwords do not match');
    }

    const user = await this.users.create({
      email: dto.email,
      password: dto.password,
      login: dto.login,
      firstName: dto.firstName,
      lastName: dto.lastName,
      phoneNumber: dto.phoneNumber,
    });
    return this.auth.signToken(user);
  }

  @Post('login')
  @ApiOperation({ summary: 'Se connecter et obtenir un JWT' })
  @ApiOkResponse({ type: AuthResponseDto })
  async login(@Body() dto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.auth.validateUser(dto.email, dto.password);
    return this.auth.signToken(user);
  }

  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Req() req: RequestWithUser) {
    return req.user;
  }
}
