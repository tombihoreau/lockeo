import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import 'reflect-metadata';
import {
  ensureProductUploadsDir,
  resolveUploadsDir,
} from './uploads/uploads-path';

async function bootstrap() {
  ensureProductUploadsDir();
  const uploadsDir = resolveUploadsDir();

  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Sécurité/CORS
  app.enableCors();
  app.setGlobalPrefix('api');
  app.useStaticAssets(uploadsDir, { prefix: '/api/uploads/' });

  // Validation globale des DTOs
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  // --- Swagger config ---
  const config = new DocumentBuilder()
    .setTitle('Lockeo API')
    .setDescription('Documentation OpenAPI pour le backend Lockeo')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        in: 'header',
      },
      'access-token',
    )
    .addTag('auth')
    .addTag('users')
    .addBearerAuth() // JWT
    .addTag('Users')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('/api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true, // garde le token entre les refresh
    },
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap().catch((err) => {
  console.error(err);
  process.exit(1);
});
