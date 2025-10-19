import { IsNotEmpty, IsString, IsDateString, IsIn, Matches } from 'class-validator';

export class GetPageSeriesDto {
   @IsNotEmpty({ message: 'El parámetro "lang" es obligatorio.' })
   @IsString({ message: 'El parámetro "lang" debe ser una cadena de texto.' })
   @IsIn(['en', 'es'], { message: 'El idioma (lang) debe ser uno de los códigos soportados: en, es.' }) 
   lang: string; 

   @IsNotEmpty({ message: 'El parámetro "date_from" (fecha de inicio) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date_from" debe ser una fecha válida.' })
   @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'date_from debe estar en formato YYYY-MM-DD.' })
   date_from: string; 

   @IsNotEmpty({ message: 'El parámetro "date_to" (fecha de fin) es obligatorio.' })
   @IsDateString({}, { message: 'El parámetro "date_to" debe ser una fecha válida.' })
   @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'date_to debe estar en formato YYYY-MM-DD.' })
   date_to: string;
}
