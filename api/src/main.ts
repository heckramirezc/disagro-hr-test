import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'; // <-- Importaciones de Swagger

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  const corsOrigins = configService.get<string>('CORS_ORIGIN') || 'http://localhost:3001';
  app.enableCors({
    origin: corsOrigins.split(','),
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  
  const config = new DocumentBuilder()
    .setTitle('API de la Prueba Técnica DISAGRO - Wikipedia Pageviews')
    .setDescription('API para obtener rankings diarios y series temporales de vistas de páginas de Wikipedia, como parte de la Prueba Técnica. Desarrollada por Hector Ramírez')
    .setVersion('1.0')
    .addTag('Páginas de Wikipedia | Fuentes de datos BigQuery/PostgreSQL')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  // La documentación estará disponible en /api-docs
  SwaggerModule.setup('api-docs', app, document);
  // ---------------------------------
  
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

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  console.log(`API Service: ACorriendo en: ${await app.getUrl()}`);
  console.log(`API Service: Documentación de Swagger disponible en: ${await app.getUrl()}/api-docs`);
}
bootstrap();
