// src/users/users.service.ts
import { Injectable, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from '../entities/user.entity';

export type CreateUserInput = {
  email: string;
  password: string;
  login?: string;
  firstName?: string | null;
  lastName?: string | null;
  phoneNumber?: string | null;
};

@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private readonly repo: Repository<User>) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.repo.findOne({ where: { email: ILike(email) } });
  }

  async findByLogin(login: string): Promise<User | null> {
    return this.repo.findOne({ where: { login } });
  }

  async create(input: CreateUserInput): Promise<User> {
    const email = input.email.trim().toLowerCase();

  const rawLogin = input.login?.trim();
  const login = rawLogin && rawLogin.length > 0 ? rawLogin : null;

    const where = [{ email }, ...(login != null ? [{ login }] : [])];
    const exists = await this.repo.findOne({ where });
    if (exists) throw new ConflictException('Email or login already in use');

    const saltRounds = 12;
    const password_hash = await bcrypt.hash(input.password, saltRounds);

    const user = this.repo.create({
      email,
      login,
      password_hash,
      first_name: input.firstName ?? null,
      last_name: input.lastName ?? null,
      phone_number: input.phoneNumber ?? null,
    } as Partial<User>);

    return this.repo.save(user);
  }

  async verifyPassword(user: User, plain: string): Promise<boolean> {
    return bcrypt.compare(plain, user.password_hash);
  }
}
