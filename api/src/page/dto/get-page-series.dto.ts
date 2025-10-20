import { IsNotEmpty, IsString, IsDateString, IsIn, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GetPageSeriesDto {
   @ApiProperty({
    description: 'Idioma a consultar (ej: "es", "en").',
    example: 'es',
    required: true,
  })
   @IsNotEmpty({ message: 'El parámetro "lang" es obligatorio.' })
   @IsString({ message: 'El parámetro "lang" debe ser una cadena de texto.' })
   @IsIn(['en', 'es'], { message: 'El idioma (lang) debe ser uno de los códigos soportados: en, es.' }) 
   lang: string; 

   @ApiProperty({
    description: 'Fecha de inicio (incluida) de la serie temporal en formato YYYY-MM-DD.',
    example: '2023-12-26',
    required: true,
  })
   @IsNotEmpty({ message: 'El parámetro "date_from" (fecha de inicio) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date_from" debe ser una fecha válida.' })
   @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'date_from debe estar en formato YYYY-MM-DD.' })
   date_from: string; 

   @ApiProperty({
    description: 'Fecha de fin (incluida) de la serie temporal en formato YYYY-MM-DD.',
    example: '2024-01-01',
    required: true,
  })
   @IsNotEmpty({ message: 'El parámetro "date_to" (fecha de fin) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date_to" debe ser una fecha válida.' })
   @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'date_to debe estar en formato YYYY-MM-DD.' })
   date_to: string;
}