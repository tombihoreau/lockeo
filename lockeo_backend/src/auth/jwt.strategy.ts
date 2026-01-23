import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { Request } from 'express';

export interface JwtPayload {
  sub: number;
  email: string;
  firstName?: string | null;
  lastName?: string | null;
  role?: string;
  iat?: number;
  exp?: number;
}

export interface AuthenticatedUser {
  userId: number;
  email: string;
  firstName?: string | null;
  lastName?: string | null;
  role?: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    // Extracteur Bearer fourni par passport-jwt (types installés)
    const bearerExtractor = ExtractJwt.fromAuthHeaderAsBearerToken();

    super({
      jwtFromRequest: bearerExtractor,
      secretOrKey: process.env.JWT_SECRET ?? 'dev-secret', // à mettre dans les variables d'environnement en prod
      ignoreExpiration: false,
    });
  }

  validate(payload: JwtPayload): AuthenticatedUser {
    const { sub, email, role, firstName, lastName } = payload;

    return {
      userId: sub,
      email,
      firstName,
      lastName,
      role,
    };
  }
}
