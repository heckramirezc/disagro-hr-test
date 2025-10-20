import { Controller, Get, Query, Param, ValidationPipe } from '@nestjs/common';
import { PageService } from './page.service';
import { GenericPaginatedResponse, PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';
import { GetPageSeriesDto } from './dto/get-page-series.dto'; 
import { PageParamsDto } from './dto/page-params.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiExtraModels, getSchemaPath, ApiProperty } from '@nestjs/swagger';
import { SeriesItem, TopPageItem, TrendingItem } from './schemas/page-response.schema';
import { GetTrendingDto } from './dto/get-trending.dto';

@ApiTags('Páginas de Wikipedia')
@ApiExtraModels(TopPageItem, TrendingItem, SeriesItem, GenericPaginatedResponse)
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

  @Get('trending')
  @ApiOperation({ 
    summary: 'Obtiene las páginas en tendencia (trending) para una fecha específica.', 
    description: 'Retorna una lista paginada de las páginas cuyo `trend_score` excede un umbral predefinido, ordenadas por dicho score.' 
  })
  @ApiResponse({
    status: 200,
    description: 'Páginas en tendencia devueltas exitosamente.',
    schema: {
      allOf: [
        { $ref: getSchemaPath(GenericPaginatedResponse) }, 
        {
          properties: {
            items: {
              type: 'array',
              items: { $ref: getSchemaPath(TrendingItem) },
              description: 'Resultados de las páginas en tendencia. El orden es descendente por trend_score.'
            },
          },
        },
      ],
    },
  })
  async getTrendingPages(
    @Query(new ValidationPipe({ transform: true })) request: GetTrendingDto,
  ): Promise<PaginatedResponse<TrendingItem>> {

    return this.pageService.getTrendingPages(request);
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
