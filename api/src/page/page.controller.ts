import { Controller, Get, Query, ValidationPipe } from '@nestjs/common';
import { PageService } from './page.service';
import { PaginatedResponse } from '../pagination/pagination.service';
import { GetTopPagesDto } from './dto/get-top-pages.dto';

@Controller('api/page') 
export class PageController {
  constructor(private readonly pageService: PageService) {}

  @Get('top')
  async getTopPages(
    @Query(new ValidationPipe({ transform: true })) request: GetTopPagesDto,
  ): Promise<PaginatedResponse<any>> {

    return this.pageService.getTopPages(request);
  }
}
