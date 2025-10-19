import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Prueba técnica de Hector Ramírez para DISAGRO';
  }
}
