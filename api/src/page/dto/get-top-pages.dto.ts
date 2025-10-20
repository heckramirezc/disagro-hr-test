import { IsOptional, IsDateString, IsString, IsIn, IsInt, Min, Max, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class GetTopPagesDto {
   @ApiProperty({
    description: 'Fecha en formato YYYY-MM-DD para consultar el ranking.',
    example: '2024-01-01',
    required: true,
  })
   @IsNotEmpty({ message: 'El parámetro "date" (YYYY-MM-DD) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date" debe ser una fecha válida en formato YYYY-MM-DD.' })
   date: string; 

   @ApiProperty({
    description: 'Idioma a consultar (ej: "es").',
    example: 'es',
    required: true,
  })
   @IsNotEmpty({ message: 'El parámetro "lang" es obligatorio.' })
   @IsString({ message: 'El parámetro "lang" debe ser una cadena de texto.' })
   @IsIn(['en', 'es'], { message: 'El idioma (lang) debe ser uno de los códigos soportados: en, es.' }) 
   lang: string; 

   @ApiProperty({
    description: 'Límite de resultados a devolver (máximo 200).',
    example: 10,
    default: 10,
    minimum: 1,
    maximum: 200,
    required: false,
  })
   @IsOptional()
   @Type(() => Number)
   @IsInt({ message: 'El parámetro "limit" debe ser un número entero.' })
   @Min(1, { message: 'El límite debe ser al menos 1.' })
   @Max(200, { message: 'El límite no puede ser superior a 200 (requisito de la prueba técnica).' })
   limit: number = 10;

   @ApiProperty({
    description: 'Desplazamiento (offset) para la paginación.',
    example: 0,
    default: 0,
    minimum: 0,
    required: false,
  })
   @IsOptional()
   @Type(() => Number)
   @IsInt({ message: 'El parámetro "offset" debe ser un número entero.' })
   @Min(0, { message: 'El offset no puede ser negativo.' })
   offset: number = 0;
}
