import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  const corsOrigins = configService.get<string>('CORS_ORIGIN') || 'http://localhost:3001';
  app.enableCors({
    origin: corsOrigins.split(','),
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  
  try {
    const dataSource = app.get(DataSource);
    if (dataSource.isInitialized) {
      console.log('API Service: Conexión a la base de datos establecida correctamente.');
    } else {
      console.error('API Service: Error: La conexión a la base de datos no se inicializó.');
    }
  } catch (error) {
    console.error('API Service: Error al intentar obtener la conexión a la base de datos:', error.message);
  }

  await app.listen(configService.get<number>('PORT') || 3000);
  console.log(`API Service: Aplicación NestJS corriendo en: ${await app.getUrl()}`);
}
bootstrap();
