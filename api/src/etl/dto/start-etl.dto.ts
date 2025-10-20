import { IsString, IsNotEmpty, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class StartEtlDto {
  @ApiProperty({
    description: 'Fecha de los datos a procesar en formato YYYY-MM-DD.',
    example: '2024-01-01',
    required: true,
  })
  @IsNotEmpty({ message: 'El parámetro "date" no debe estar vacío.' })
  @IsDateString({}, { message: 'El parámetro "date" debe ser una fecha válida en formato ISO (YYYY-MM-DD).' })
  date: string;

  @ApiProperty({
    description: 'Idioma o lista de idiomas a procesar (ej: "es", "en", "es,en").',
    example: 'es,en,fr',
    required: true,
  })
  @IsNotEmpty({ message: 'El parámetro "lang" no debe estar vacío.' })
  @IsString({ message: 'El parámetro "lang" debe ser una cadena de texto válida.' })
  lang: string;
}
