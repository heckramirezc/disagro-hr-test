import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

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

  await app.listen(process.env.PORT || 3000);
  console.log(`API Service: Aplicación NestJS corriendo en: ${await app.getUrl()}`);
}
bootstrap();
