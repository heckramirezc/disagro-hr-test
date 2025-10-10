-- 1. Índices en tabla fact_pageviews_daily
CREATE INDEX IF NOT EXISTS idx_fact_pageviews_daily_day ON fact_pageviews_daily (day);
CREATE INDEX IF NOT EXISTS idx_fact_pageviews_daily_page_id ON fact_pageviews_daily (page_id);
CREATE INDEX IF NOT EXISTS idx_fact_pageviews_daily_language ON fact_pageviews_daily (language);
CREATE INDEX IF NOT EXISTS idx_fact_pageviews_daily_views_total ON fact_pageviews_daily (views_total DESC);
CREATE INDEX IF NOT EXISTS idx_fact_pageviews_daily_trend_score ON fact_pageviews_daily (trend_score DESC);

-- 2. Índice compuesto útil para la API (Ranking y Tendencia por día/idioma)
CREATE INDEX IF NOT EXISTS idx_fact_day_lang_views_trend 
    ON fact_pageviews_daily (day, language, views_total DESC, trend_score DESC);