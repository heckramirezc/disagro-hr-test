import { IsOptional, IsDateString, IsString, IsIn, IsInt, Min, Max, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';

export class GetTopPagesDto {
   @IsNotEmpty({ message: 'El parámetro "date" (YYYY-MM-DD) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date" debe ser una fecha válida en formato YYYY-MM-DD.' })
   date: string; 

   @IsNotEmpty({ message: 'El parámetro "lang" es obligatorio.' })
   @IsString({ message: 'El parámetro "lang" debe ser una cadena de texto.' })
   @IsIn(['en', 'es'], { message: 'El idioma (lang) debe ser uno de los códigos soportados: en, es.' }) 
   lang: string; 

   @IsOptional()
   @Type(() => Number)
   @IsInt({ message: 'El parámetro "limit" debe ser un número entero.' })
   @Min(1, { message: 'El límite debe ser al menos 1.' })
   @Max(200, { message: 'El límite no puede ser superior a 200 (requisito de la prueba técnica).' })
   limit: number = 10;

   @IsOptional()
   @Type(() => Number)
   @IsInt({ message: 'El parámetro "offset" debe ser un número entero.' })
   @Min(0, { message: 'El offset no puede ser negativo.' })
   offset: number = 0;
}
