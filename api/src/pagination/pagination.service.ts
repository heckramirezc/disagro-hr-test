import { Injectable } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';

export interface PaginatedResponse<T> {
  items: T[];
  page: number;
  page_size: number;
  total: number;
  params: Record<string, any>;
}

export class GenericPaginatedResponse<T> {
  @ApiProperty({ isArray: true, description: 'Lista de elementos devueltos en la página actual.' })
  items: T[];

  @ApiProperty({ type: Number, description: 'Número de página actual (empezando en 1).' })
  page: number;

  @ApiProperty({ type: Number, description: 'Tamaño máximo de la página (limit) o total de ítems si no hay paginación.' })
  page_size: number;

  @ApiProperty({ type: Number, description: 'Número total de ítems disponibles en la consulta.' })
  total: number;

  @ApiProperty({ type: Object, description: 'Parámetros de consulta utilizados para generar esta respuesta.' })
  params: Record<string, any>;
}

@Injectable()
export class PaginationService {
  public buildPaginatedResponse<T>(
    items: T[],
    total: number,
    limit: number,
    offset: number,
    params: Record<string, any>,
  ): PaginatedResponse<T> {
    const page = total > 0 ? (offset === 0 ? 1 : Math.floor(offset / limit) + 1) : 0;
    const page_size = limit;

    return {
      items,
      page,
      page_size,
      total,
      params,
    };
  }
  
  public buildSeriesResponse<T>(
    items: T[],
    params: Record<string, any>,
  ): PaginatedResponse<T> {
    const totalItems = items.length;

    return {
      items,
      page: 1,
      page_size: totalItems,
      total: totalItems,
      params,
    };
  }
}
