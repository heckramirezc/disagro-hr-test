import { IsString, Matches } from 'class-validator';

export class PageParamsDto {
  @Matches(/\S+/, { 
    message: 'El parámetro de ruta "title" es obligatorio y no puede estar vacío ni contener solo espacios.' 
  })
  @IsString({ message: 'El parámetro de ruta "title" debe ser una cadena de texto válida.' })
  title: string;
}
