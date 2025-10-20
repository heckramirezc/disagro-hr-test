-- Extensión para generar UUIDs  de forma segura
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabla para el registro y seguimiento del estado de cada trabajo ETL, facilitando su orquestación y monitoreo desde el frontend. 
CREATE TABLE IF NOT EXISTS etl_jobs (
    job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) NOT NULL,
    params JSONB,
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    job_type VARCHAR(50) NOT NULL,
    data_date DATE,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    finished_at TIMESTAMP WITH TIME ZONE,
    worker_id VARCHAR(100),
    rows_processed INT,
    error_message TEXT
);

-- Tabla de Dimensión
CREATE TABLE IF NOT EXISTS dim_page (
    page_id SERIAL PRIMARY KEY,
    title_normalized VARCHAR(255) NOT NULL,
    original_title VARCHAR(255) NOT NULL,
    language VARCHAR(10) NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (title_normalized, language) -- Garantiza una página por título e idioma. 
);

-- Tabla de Hechos Diarios de Vistas
-- Se desnormaliza 'language' aquí para mejorar el rendimiento de consulta/indexación
-- y para cumplir con el requisito de indexar directamente 'lang'
CREATE TABLE IF NOT EXISTS fact_pageviews_daily (
    fact_id SERIAL PRIMARY KEY,
    day DATE NOT NULL,
    page_id INTEGER NOT NULL REFERENCES dim_page(page_id),
    language VARCHAR(10) NOT NULL, -- Incluido para optimizar consultas; es intencionalmente redundante con dim_page.language.
    views_total BIGINT NOT NULL,
    avg_views_7d NUMERIC,
    avg_views_28d NUMERIC,
    variations NUMERIC,
    trend_score NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (day, page_id, language) -- Garantiza un registro por página, fecha e idioma
);