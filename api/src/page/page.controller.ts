import { Controller, Get, Query, Param, ValidationPipe } from '@nestjs/common';
import { PageService } from './page.service';
import { GenericPaginatedResponse, PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';
import { GetPageSeriesDto } from './dto/get-page-series.dto'; 
import { PageParamsDto } from './dto/page-params.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiExtraModels, getSchemaPath, ApiProperty } from '@nestjs/swagger';
import { SeriesItem, TopPageItem } from './schemas/age-response.schema';

@ApiTags('Páginas de Wikipedia')
@ApiExtraModels(TopPageItem, SeriesItem, GenericPaginatedResponse)
@Controller('api/page') 
export class PageController {
  constructor(private readonly pageService: PageService) {}

  @Get('top')
  @ApiOperation({ 
    summary: 'Obtiene el ranking de las páginas más vistas para una fecha específica.', 
    description: 'Retorna una lista paginada de las páginas más vistas por un día y idioma determinado.' })
  @ApiResponse({
    status: 200,
    description: 'Ranking de páginas devuelto exitosamente.',
    schema: {
      allOf: [
        { $ref: getSchemaPath(GenericPaginatedResponse) },
        {
          properties: {
            items: {
              type: 'array',
              items: { $ref: getSchemaPath(TopPageItem) },
              description: 'Resultados del ranking. El orden es descendente por views_total.'
            },
          },
        },
      ],
    },
  })
  async getTopPages(
    @Query(new ValidationPipe({ transform: true })) request: GetTopPagesDto,
  ): Promise<PaginatedResponse<any>> {

    return this.pageService.getTopPages(request);
  }

  @Get(':title')
  @ApiOperation({ 
    summary: 'Obtiene la serie temporal de vistas y métricas derivadas para una página específica.', 
    description: 'Retorna la serie de datos diaria de una página, incluyendo vistas, promedios móviles, y score de tendencia, para el rango de fechas solicitado.' 
  })
  @ApiParam({ 
    name: 'title', 
    description: 'Título normalizado de la página.', 
    type: String, 
    example: 'dia_de_ano_nuevo' 
  })
  @ApiResponse({
    status: 200,
    description: 'Serie temporal devuelta exitosamente. Se utiliza la estructura PaginatedResponse, pero sin paginación.',
    schema: {
      allOf: [
        { $ref: getSchemaPath(GenericPaginatedResponse) },
        {
          properties: {
            items: {
              type: 'array',
              items: { $ref: getSchemaPath(SeriesItem) },
              description: 'Resultados de la serie temporal día por día.'
            },
          },
        },
      ],
    },
  })
  async getPageSeries(
    @Param(new ValidationPipe({ transform: true })) params: PageParamsDto,
    @Query(new ValidationPipe({ transform: true })) request: GetPageSeriesDto,
  ): Promise<PaginatedResponse<any>> {

    return this.pageService.getPageSeries(params, request);
  }
}
