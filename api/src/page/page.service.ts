import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { PaginationService, PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';

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
      return this.paginationService.buildResponse([], 0, safeLimit, safeOffset, _params);
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
    return this.paginationService.buildResponse(items, total, safeLimit, safeOffset, _params);
  }
}
