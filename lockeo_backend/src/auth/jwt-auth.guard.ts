import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest<TUser = unknown>(
    err: any,
    user: TUser,
    info: unknown,
    context: unknown,
    status?: unknown,
  ): TUser {
    void context;
    void status;
    if (err || !user) {
      const message = info instanceof Error ? info.message : 'Unauthorized';
      throw err instanceof Error ? err : new UnauthorizedException(message);
    }
    return user;
  }
}
