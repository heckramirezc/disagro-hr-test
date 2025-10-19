import { Module } from '@nestjs/common';
import { PageController } from './page.controller';
import { PageService } from './page.service';
import { PaginationService } from '../pagination/pagination.service';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [TypeOrmModule.forFeature([])],
  controllers: [PageController],
  providers: [
    PageService, 
    PaginationService
  ],
})
export class PageModule {}
