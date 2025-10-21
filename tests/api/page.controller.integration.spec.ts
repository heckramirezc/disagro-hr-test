import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, BadRequestException, ValidationPipe } from '@nestjs/common';
import supertest from 'supertest';
import { PageController } from '../../api/src/page/page.controller';
import { PageService } from '../../api/src/page/page.service';
import { GetTopPagesDto } from '../../api/src/page/dto/get-top-pages.dto';
import { GetTrendingDto } from '../../api/src/page/dto/get-trending.dto';
import { GetPageSeriesDto } from '../../api/src/page/dto/get-page-series.dto';

describe('Pruebas de integración - Servicio de Páginas (Wikipedia)', () => {
  let app: INestApplication;
  const routeTop = '/api/page/top';
  const routeTrending = '/api/page/trending';
  const routeTitle = 'NestJS-Documentation';

  const mockPageService = {
    getTopPages: jest.fn(),
    getTrendingPages: jest.fn(),
    getPageSeries: jest.fn(),
  };

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PageController],
      providers: [{ provide: PageService, useValue: mockPageService }],
    }).compile();

    app = module.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
        disableErrorMessages: false,
      }),
    );

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // -----------------------------
  // GET /api/page/top
  // -----------------------------
  describe('GET /api/page/top', () => {
    const mockTopResponse = [
      { page: 'Page A', views: 100 },
      { page: 'Page B', views: 90 },
    ];

    beforeEach(() => {
      mockPageService.getTopPages.mockResolvedValue(mockTopResponse);
    });

    it('debería devolver 200 y llamar al servicio con DTO válido', async () => {
      const response = await supertest(app.getHttpServer())
        .get(routeTop)
        .query({ date: '2025-10-01', lang: 'es', limit: 10, offset: 0 })
        .expect(200);

      expect(mockPageService.getTopPages).toHaveBeenCalledWith(
        expect.objectContaining<GetTopPagesDto>({
          date: '2025-10-01',
          lang: 'es',
          limit: 10,
          offset: 0,
        }),
      );

      expect(response.body).toEqual(mockTopResponse);
    });

    it('debería devolver 400 si falta el parámetro "date"', async () => {
      await supertest(app.getHttpServer())
        .get(routeTop)
        .query({ lang: 'es', limit: 10, offset: 0 })
        .expect(400);

      expect(mockPageService.getTopPages).not.toHaveBeenCalled();
    });

    it('debería devolver 400 si "limit" no es un número', async () => {
      await supertest(app.getHttpServer())
        .get(routeTop)
        .query({ date: '2025-10-01', lang: 'es', limit: 'invalid', offset: 0 })
        .expect(400);

      expect(mockPageService.getTopPages).not.toHaveBeenCalled();
    });
  });

  // -----------------------------
  // GET /api/page/trending
  // -----------------------------
  describe('GET /api/page/trending', () => {
    const mockTrendingResponse = [
      { page: 'Page X', views: 50, views_change: 15 },
    ];

    beforeEach(() => {
      mockPageService.getTrendingPages.mockResolvedValue(mockTrendingResponse);
    });

    it('debería devolver 200 y llamar al servicio con DTO válido', async () => {
      const response = await supertest(app.getHttpServer())
        .get(routeTrending)
        .query({ date: '2025-10-01', lang: 'en', limit: 5, offset: 0 })
        .expect(200);

      expect(mockPageService.getTrendingPages).toHaveBeenCalledWith(
        expect.objectContaining<GetTrendingDto>({
          date: '2025-10-01',
          lang: 'en',
          limit: 5,
          offset: 0,
        }),
      );

      expect(response.body).toEqual(mockTrendingResponse);
    });

    it('debería devolver 400 si falta el parámetro "lang"', async () => {
      await supertest(app.getHttpServer())
        .get(routeTrending)
        .query({ date: '2025-10-01', limit: 5, offset: 0 })
        .expect(400);

      expect(mockPageService.getTrendingPages).not.toHaveBeenCalled();
    });
  });

  // -----------------------------
  // GET /api/page/:title
  // -----------------------------
  describe('GET /api/page/:title', () => {
    const mockSeriesResponse = [
      { timestamp: '2025-10-01', views: 100 },
      { timestamp: '2025-10-02', views: 105 },
    ];

    beforeEach(() => {
      mockPageService.getPageSeries.mockResolvedValue(mockSeriesResponse);
    });

    it('debería devolver 200 y la serie temporal', async () => {
      const response = await supertest(app.getHttpServer())
        .get(`/api/page/${routeTitle}`)
        .query({ lang: 'es', date_from: '2025-10-01', date_to: '2025-10-05' })
        .expect(200);

      expect(mockPageService.getPageSeries).toHaveBeenCalledWith(
        { title: routeTitle },
        expect.objectContaining<GetPageSeriesDto>({
          lang: 'es',
          date_from: '2025-10-01',
          date_to: '2025-10-05',
        }),
      );

      expect(response.body).toEqual(mockSeriesResponse);
    });

    it('debería devolver 400 si falta un parámetro requerido (date_from)', async () => {
      await supertest(app.getHttpServer())
        .get(`/api/page/${routeTitle}`)
        .query({ lang: 'es', date_to: '2025-10-05' })
        .expect(400);

      expect(mockPageService.getPageSeries).not.toHaveBeenCalled();
    });

    it('debería devolver 400 si el servicio lanza BadRequestException', async () => {
      mockPageService.getPageSeries.mockRejectedValue(
        new BadRequestException('Invalid date range'),
      );

      await supertest(app.getHttpServer())
        .get(`/api/page/${routeTitle}`)
        .query({ lang: 'es', date_from: '2025-10-01', date_to: '2025-10-05' })
        .expect(400)
        .expect((res) => {
          expect(res.body.message).toEqual('Invalid date range');
          expect(res.body.error).toEqual('Bad Request');
        });

      expect(mockPageService.getPageSeries).toHaveBeenCalledTimes(1);
    });
  });
});
