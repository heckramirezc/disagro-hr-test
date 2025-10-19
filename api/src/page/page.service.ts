import { Injectable, BadRequestException } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { PaginationService, PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';
import { GetPageSeriesDto } from './dto/get-page-series.dto';
import { PageParamsDto } from './dto/page-params.dto';

@Injectable()
export class PageService {
  constructor(
    private dataSource: DataSource,
    private paginationService: PaginationService,
  ) {}

  async getTopPages(
    request: GetTopPagesDto
  ): Promise<PaginatedResponse<any>> {
    const safeLimit = Math.min(request.limit, 200);
    const safeOffset = Math.max(request.offset, 0);
    const _params = { 
      date: request.date, 
      lang: request.lang, 
      limit: safeLimit, 
      offset: safeOffset 
    };

    const totalQuery = `
      SELECT 
        COUNT(*) AS total
      FROM 
        mv_top_n_daily_by_language
      WHERE 
        day = $1 AND language = $2;
    `;
    const totalResult = await this.dataSource.query(totalQuery, [request.date, request.lang]);
    const total = parseInt(totalResult[0]?.total, 10) || 0;

    if (total === 0) {
      return this.paginationService.buildPaginatedResponse([], 0, safeLimit, safeOffset, _params);
    }

    const itemsQuery = `
      SELECT
        day,
        language,
        title_normalized AS title,
        views_total,
        rank_by_views AS rank
      FROM 
        mv_top_n_daily_by_language
      WHERE 
        day = $1 AND language = $2
      ORDER BY 
        rank_by_views ASC
      LIMIT $3 OFFSET $4;
    `;
    const items = await this.dataSource.query(itemsQuery, [request.date, request.lang, safeLimit, safeOffset]);
    return this.paginationService.buildPaginatedResponse(items, total, safeLimit, safeOffset, _params);
  }

  async getPageSeries(
    params: PageParamsDto,
    request: GetPageSeriesDto,
  ): Promise<PaginatedResponse<any>> {
    
    if (new Date(request.date_from).toString() === 'Invalid Date' || new Date(request.date_to).toString() === 'Invalid Date') {
        throw new BadRequestException('Las fechas de inicio y fin deben ser válidas (YYYY-MM-DD).');
    }

    const _params = { 
      title: params.title, 
      lang: request.lang, 
      date_from: request.date_from, 
      date_to: request.date_to 
    };
    const pageIdQuery = `
      SELECT 
        page_id, category
      FROM 
        dim_page
      WHERE 
        title_normalized = $1 AND language = $2;
    `;
    const pageResult = await this.dataSource.query(pageIdQuery, [params.title, request.lang]);
    if (pageResult.length === 0) {
      return this.paginationService.buildSeriesResponse([], _params);
    }

    const pageId = pageResult[0].page_id;
    const category = pageResult[0].category;

    const seriesQuery = `
      SELECT
        fpd.day,
        fpd.views_total,
        fpd.avg_views_7d,
        fpd.avg_views_28d,
        fpd.variations,
        fpd.trend_score,
        $2 AS category -- Ahora $2, se pasa como una columna constante
      FROM 
        fact_pageviews_daily fpd
      WHERE 
        fpd.page_id = $1 AND fpd.day BETWEEN $3 AND $4
      ORDER BY fpd.day ASC;
    `;

    const items = await this.dataSource.query(seriesQuery, [pageId, category, request.date_from, request.date_to]); 
    return this.paginationService.buildSeriesResponse(items, _params);
  }
}
