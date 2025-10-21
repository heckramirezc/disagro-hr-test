import { Test, TestingModule } from '@nestjs/testing';
import { DataSource } from 'typeorm';
import { BadRequestException } from '@nestjs/common';
import { PageService } from '../../api/src/page/page.service';
import { PaginationService } from '../../api/src/pagination/pagination.service';
import { GetTopPagesDto } from '../../api/src/page/dto/get-top-pages.dto';
import { GetTrendingDto } from '../../api/src/page/dto/get-trending.dto';
import { GetPageSeriesDto } from '../../api/src/page/dto/get-page-series.dto';
import { PageParamsDto } from '../../api/src/page/dto/page-params.dto';

// --- Mocks ---
const mockPaginationService = {
  buildPaginatedResponse: jest.fn((items, total, limit, offset, params) => ({
    items,
    page: Math.floor(offset / limit) + 1,
    page_size: limit,
    total,
    params,
  })),
  buildSeriesResponse: jest.fn((items, params) => ({
    items,
    params,
  })),
};

const mockDataSource = {
  query: jest.fn(),
};

describe('Servicio de Páginas (Wikipedia)', () => {
  let service: PageService;
  let dataSource: DataSource;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PageService,
        { provide: DataSource, useValue: mockDataSource },
        { provide: PaginationService, useValue: mockPaginationService },
      ],
    }).compile();

    service = module.get<PageService>(PageService);
    dataSource = module.get<DataSource>(DataSource);

    jest.clearAllMocks();
  });

  it('debería estar definido', () => {
    expect(service).toBeDefined();
  });

  // Pruebas para getTopPages
  describe('getTopPages', () => {
    const solicitudTopPages: GetTopPagesDto = {
      date: '2025-10-01',
      lang: 'es',
      limit: 10,
      offset: 0,
    };
    const itemsMock = [{ title: 'Page A', rank: 1, views_total: 1000 }];

    it('debería devolver datos paginados si el total es mayor que 0', async () => {
      mockDataSource.query.mockResolvedValueOnce([{ total: '50' }]); // total
      mockDataSource.query.mockResolvedValueOnce(itemsMock);        // items

      const resultado = await service.getTopPages(solicitudTopPages);

      expect(dataSource.query).toHaveBeenCalledTimes(2);
      expect(resultado.items).toEqual(itemsMock);
      expect(resultado.total).toBe(50);
    });

    it('debería devolver respuesta vacía si el total es 0', async () => {
      mockDataSource.query.mockResolvedValueOnce([{ total: '0' }]);

      const resultado = await service.getTopPages(solicitudTopPages);

      expect(dataSource.query).toHaveBeenCalledTimes(1);
      expect(resultado.items).toEqual([]);
      expect(resultado.total).toBe(0);
    });

    it('debería respetar el límite máximo (200) aunque se solicite más', async () => {
      const solicitudGranLimite: GetTopPagesDto = { ...solicitudTopPages, limit: 500 };
      mockDataSource.query.mockResolvedValueOnce([{ total: '1' }]);
      mockDataSource.query.mockResolvedValueOnce(itemsMock);

      await service.getTopPages(solicitudGranLimite);

      const llamadaItems = mockDataSource.query.mock.calls[1];
      const limiteParam = llamadaItems[1][2];
      expect(limiteParam).toBe(200);
    });
  });

  // Pruebas para getTrendingPages
  describe('getTrendingPages', () => {
    const solicitudTrending: GetTrendingDto = {
      date: '2025-10-02',
      lang: 'en',
      limit: 5,
      offset: 0,
    };
    const itemsTrendingMock = [{ title: 'Trend A', trend_score: 1.5, views_total: 800 }];

    it('debería devolver páginas trending ordenadas por score', async () => {
      mockDataSource.query.mockResolvedValueOnce([{ total: '10' }]);
      mockDataSource.query.mockResolvedValueOnce(itemsTrendingMock);

      const resultado = await service.getTrendingPages(solicitudTrending);

      const llamadaItems = mockDataSource.query.mock.calls[1];
      expect(llamadaItems[0]).toContain('mv_trending_daily');

      const sqlNormalizado = llamadaItems[0].replace(/\s+/g, ' ');
      expect(sqlNormalizado).toContain('ORDER BY t.trend_score DESC');

      expect(resultado.items).toEqual(itemsTrendingMock);
      expect(resultado.total).toBe(10);
    });
  });

    // Pruebas para getPageSeries
  describe('getPageSeries', () => {
    const params: PageParamsDto = { title: 'python_prog' };
    const request: GetPageSeriesDto = {
      lang: 'es',
      date_from: '2025-01-01',
      date_to: '2025-01-05',
    };
    const pageMock = [{ page_id: 123, category: 'Tecnologia', original_title: 'Python Prog' }];
    const seriesMock = [{ day: '2025-01-01', views_total: 100, avg_views_7d: 50, trend_score: 0.5 }];

    it('debería devolver serie temporal con métricas derivadas', async () => {
      mockDataSource.query.mockResolvedValueOnce(pageMock);
      mockDataSource.query.mockResolvedValueOnce(seriesMock);

      const resultado = await service.getPageSeries(params, request);

      const llamadaPage = mockDataSource.query.mock.calls[0];
      expect(llamadaPage[0]).toContain('dim_page');
      expect(llamadaPage[1]).toEqual([params.title, request.lang]);

      const llamadaSeries = mockDataSource.query.mock.calls[1];
      expect(llamadaSeries[0]).toContain('fact_pageviews_daily');
      expect(llamadaSeries[1][0]).toEqual(pageMock[0].page_id);
      expect(llamadaSeries[1][1]).toEqual(pageMock[0].category);

      expect(resultado.items).toEqual(seriesMock);
    });

    it('debería lanzar BadRequestException si el formato de fecha es inválido', async () => {
      const requestInvalido: GetPageSeriesDto = { ...request, date_from: '2025/01/01' };
      await expect(service.getPageSeries(params, requestInvalido)).rejects.toThrow(BadRequestException);
      expect(mockDataSource.query).not.toHaveBeenCalled();
    });

    it('debería devolver respuesta vacía si la página no se encuentra', async () => {
      mockDataSource.query.mockResolvedValueOnce([]);

      const resultado = await service.getPageSeries(params, request);

      expect(dataSource.query).toHaveBeenCalledTimes(1);
      expect(resultado.items).toEqual([]);
    });
  });
});
