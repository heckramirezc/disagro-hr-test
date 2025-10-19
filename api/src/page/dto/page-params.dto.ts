import { IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PageParamsDto {
  @ApiProperty({
    description: 'Título normalizado de la página de Wikipedia a consultar. (Va en la URL de endpoint).',
    example: 'dia_de_ano_nuevo',
    required: true,
  })
  @Matches(/\S+/, { 
    message: 'El parámetro de ruta "title" es obligatorio y no puede estar vacío ni contener solo espacios.' 
  })
  @IsString({ message: 'El parámetro de ruta "title" debe ser una cadena de texto válida.' })
  title: string;
}
