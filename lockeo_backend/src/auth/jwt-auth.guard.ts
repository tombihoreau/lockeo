import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: unknown, user: unknown, info: unknown): unknown {
    if (err || !user) {
      const message = info instanceof Error ? info.message : 'Unauthorized';
      throw err instanceof Error ? err : new UnauthorizedException(message);
    }
    return user;
  }
}
