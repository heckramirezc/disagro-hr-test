import { Controller, Get, Query, Param, ValidationPipe } from '@nestjs/common';
import { PageService } from './page.service';
import { PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';
import { GetPageSeriesDto } from './dto/get-page-series.dto'; 
import { PageParamsDto } from './dto/page-params.dto';

@Controller('api/page') 
export class PageController {
  constructor(private readonly pageService: PageService) {}

  @Get('top')
  async getTopPages(
    @Query(new ValidationPipe({ transform: true })) request: GetTopPagesDto,
  ): Promise<PaginatedResponse<any>> {

    return this.pageService.getTopPages(request);
  }

  @Get(':title')
  async getPageSeries(
    @Param(new ValidationPipe({ transform: true })) params: PageParamsDto,
    @Query(new ValidationPipe({ transform: true })) request: GetPageSeriesDto,
  ): Promise<PaginatedResponse<any>> {

    return this.pageService.getPageSeries(params, request);
  }
}
