import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import 'reflect-metadata';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

// Sécurité/CORS (optionnel)
  app.enableCors();

  // Validation globale des DTOs
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  // --- Swagger config ---
  const config = new DocumentBuilder()
    .setTitle('Lockeo API')
    .setDescription('Documentation OpenAPI pour le backend Lockeo')
    .setVersion('1.0.0')
    .addBearerAuth() // si tu utilises JWT
    .addTag('auth')
    .addTag('users')
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
