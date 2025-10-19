import { Injectable } from '@nestjs/common';

export interface PaginatedResponse<T> {
  items: T[];
  page: number;
  page_size: number;
  total: number;
  params: Record<string, any>;
}

@Injectable()
export class PaginationService {
  public buildResponse<T>(
    items: T[],
    total: number,
    limit: number,
    offset: number,
    params: Record<string, any>,
  ): PaginatedResponse<T> {
    const page = offset === 0 ? 1 : Math.floor(offset / limit) + 1;
    const page_size = limit;

    return {
      items,
      page,
      page_size,
      total,
      params,
    };
  }
}
