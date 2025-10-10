-- 1. Vista materializada para el Top-N diario por idioma (Ranking)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_top_n_daily_by_language AS
SELECT
    fpd.day,
    fpd.language,
    dp.title_normalized,
    fpd.views_total,
    -- Calculo del ranking (día/idioma) agrupado
    RANK() OVER (PARTITION BY fpd.day, fpd.language ORDER BY fpd.views_total DESC) as rank_by_views
FROM
    fact_pageviews_daily fpd
JOIN
    dim_page dp ON fpd.page_id = dp.page_id
WHERE
    fpd.views_total IS NOT NULL
WITH DATA;

-- Índice para vista materializada de Top-N
CREATE INDEX IF NOT EXISTS idx_mv_top_n_daily_language_rank
    ON mv_top_n_daily_by_language (day, language, rank_by_views);

CREATE INDEX IF NOT EXISTS idx_mv_top_n_daily_day_language 
    ON mv_top_n_daily_by_language (day, language);


-- 2. Vista materializada de tendencia diaria (Umbral)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trending_daily AS
SELECT
    fpd.day,
    fpd.language,
    dp.title_normalized,
    fpd.views_total,
    fpd.trend_score
FROM
    fact_pageviews_daily fpd
JOIN
    dim_page dp ON fpd.page_id = dp.page_id
WHERE
    fpd.trend_score IS NOT NULL AND fpd.trend_score >= 2.0 -- Umbral de tendencia elegido: 2.0 o superior
WITH DATA;

-- Índice para vista materializada de Trending
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_trending_daily_day_lang_title 
    ON mv_trending_daily (day, language, title_normalized);
CREATE INDEX IF NOT EXISTS idx_mv_trending_daily_day_lang_trend 
    ON mv_trending_daily (day, language, trend_score DESC);
