import { ApiProperty } from "@nestjs/swagger";

// (GET /top)
export class TopPageItem {
  @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Día del ranking.' })
  day: string;
  
  @ApiProperty({ example: 'es', description: 'Idioma de la página.' })
  language: string;
  
  @ApiProperty({ example: 'dia_de_ano_nuevo', description: 'Título de la página.' })
  title: string;
  
  @ApiProperty({ example: 'Día de Año Nuevo', description: 'Título original de la página.', required: false })
  original_title: string;
  
  @ApiProperty({ example: '324919', description: 'Vistas totales en el día.' })
  views_total: string;
  
  @ApiProperty({ example: '1', description: 'Posición en el ranking.' })
  rank: string;
}

// (GET /trending)
export class TrendingItem {
  @ApiProperty({ example: '2024-01-01', description: 'Día de la métrica (YYYY-MM-DD).' })
  day: string;

  @ApiProperty({ example: 'es', description: 'Idioma de la página.' })
  language: string;
  
  @ApiProperty({ example: 'dia_de_ano_nuevo', description: 'Título de la página.' })
  title: string;

  @ApiProperty({ example: 'Día de Año Nuevo', description: 'Título original de la página.', required: false })
  original_title: string;

  @ApiProperty({ example: 2.85, description: 'Puntuación de tendencia (trend_score), calculada como Z-score.' })
  trend_score: string;

  @ApiProperty({ example: 500000, description: 'Vistas totales registradas para ese día.' })
  views_total: number;

  @ApiProperty({ example: 'General', description: 'Categoría de la página (e.g., Cine_TV, Deportes).' })
  category: string;
}

// (GET /page/:title)
export class SeriesItem {
  @ApiProperty({ example: '2023-12-26T00:00:00.000Z', description: 'Día del registro.' })
  day: string;

  @ApiProperty({ example: 'Día de Año Nuevo', description: 'Título original de la página.', required: false })
  original_title: string;
  
  @ApiProperty({ example: '1199', description: 'Vistas totales en el día.' })
  views_total: string;
  
  @ApiProperty({ example: '1250.5', description: 'Media de vistas de los últimos 7 días.' })
  avg_views_7d: string;
  
  @ApiProperty({ example: '0.7071', description: 'Puntuación de tendencia.' })
  trend_score: string;
  
  @ApiProperty({ example: 'General', description: 'Categoría de la página (e.g., Cine_TV, Deportes).' })
  category: string;
}
