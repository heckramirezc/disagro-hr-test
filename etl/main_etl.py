import os
import sys
import json
from datetime import datetime
from google.cloud import bigquery
import pandas as pd
import unicodedata
import psycopg2
from psycopg2 import extras
from math import ceil
import re
import numpy as np
from typing import Optional, List

BIGQUERY_PROJECT_ID = os.getenv("BIGQUERY_PROJECT_ID", "disagro-hr-test")
PUBLIC_DATA_ID = "bigquery-public-data"
BIGQUERY_DATASET = "wikipedia"
BIGQUERY_TABLE_PREFIX = "pageviews_"
DIM_BATCH_SIZE = 500

def get_db_connection():
    HOST = os.getenv('DB_HOST')
    USER = os.getenv('DB_USER')
    PASSWORD = os.getenv('DB_PASSWORD')
    NAME = os.getenv('DB_NAME')
    SSLMODE = os.getenv('DB_SSLMODE', 'require')

    if not HOST:
        print("ERROR: Variable de entorno DB_HOST no está configurada.")
        return None

    try:
        conn = psycopg2.connect(
            host=HOST,
            user=USER,
            password=PASSWORD,
            dbname=NAME,
            sslmode=SSLMODE,
            connect_timeout=10
        )
        return conn
    except psycopg2.Error as error:
        print(f"Error al conectar a PostgreSQL: {error}")
        return None

def register_etl_job_start(start_date: str, end_date: str, languages: List[str], worker_id: str = "worker-python-01") -> Optional[str]:
    conn = get_db_connection()
    if conn is None:
        return None

    try:
        cur = conn.cursor()
        
        job_parameters = {
            "start_date": start_date,
            "end_date": end_date,
            "languages": languages,
        }
        job_parameters_json = json.dumps(job_parameters)
        insert_query = """
            INSERT INTO etl_jobs (
                status, job_type, data_date, requested_at, started_at, worker_id, params, message
            )
            VALUES (
                'INICIADO', 
                'INGESTA_DIARIA', 
                %s,
                NOW(), 
                NOW(), 
                %s,
                %s,  -- Ahora inserta la cadena JSON
                'Job registrado e inicializado.'
            )
            RETURNING job_id;
        """
        
        cur.execute(insert_query, (start_date, worker_id, job_parameters_json))        
        job_id = cur.fetchone()[0]
        conn.commit()
        print(f"Job ETL registrado exitosamente con ID: {job_id}")
        return job_id

    except (Exception, psycopg2.Error) as error:
        print(f"ERROR: No se pudo registrar el Job ETL en la base de datos: {error}")
        if conn:
            conn.rollback()
        return None
    finally:
        if conn:
            cur.close()
            conn.close()

def get_bigquery_client():
    try:
        client = bigquery.Client(project=BIGQUERY_PROJECT_ID)
        return client
    except Exception as e:
        print(f"Error al inicializar cliente de BigQuery: {e}")
        raise

def normalize_string(text):
    if pd.isna(text):
        return text
    
    normalized = unicodedata.normalize('NFD', str(text))
    cleaned = ''.join(c for c in normalized if unicodedata.category(c) != 'Mn')
    return cleaned

def extract_pageviews(
    client: bigquery.Client,
    start_date: datetime,
    end_date: datetime,
    languages: list[str],
    rank_by_views: int,
    exclude_automated_traffic: bool = True
) -> pd.DataFrame:
    all_data = []

    current_year = start_date.year
    while current_year <= end_date.year:
        table_id = f"{PUBLIC_DATA_ID}.{BIGQUERY_DATASET}.{BIGQUERY_TABLE_PREFIX}{current_year}"
        lang_filter = ", ".join([f"'{lang}'" for lang in languages])
        date_where_clause = f"""
            FORMAT_TIMESTAMP('%Y%m%d', datehour) BETWEEN '{start_date.strftime('%Y%m%d')}' AND '{end_date.strftime('%Y%m%d')}'
        """
        
        automated_traffic_filter = ""
        if exclude_automated_traffic:
            automated_traffic_filter = """
                AND title NOT IN ('Main_Page', 'Special:Search', '404_error_page', 'Portal:Current_events')
                AND title NOT LIKE 'File:%' AND title NOT LIKE 'MediaWiki:%'
                AND title NOT LIKE 'User:%' AND title NOT LIKE 'Wikipedia:%'
                AND title NOT LIKE 'Talk:%'
                AND title NOT LIKE 'Template:%'
            """
        
        if rank_by_views > 0:
            query = f"""
                WITH AggregatedViews AS (
                    SELECT
                        DATE(datehour) AS day,
                        REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') AS language,
                        CASE
                            WHEN REGEXP_CONTAINS(wiki, r'\.m$') THEN 'mobile'
                            ELSE 'desktop'
                        END AS platform_type,
                        title,
                        SUM(views) AS views
                    FROM
                        `{table_id}`
                    WHERE
                        {date_where_clause}
                        AND REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') IN ({lang_filter})
                        {automated_traffic_filter}
                    GROUP BY 1, 2, 3, 4
                ),
                RankedViews AS (
                    SELECT
                        *,
                        ROW_NUMBER() OVER (
                            PARTITION BY day, language, platform_type
                            ORDER BY views DESC
                        ) AS rank_by_views
                    FROM
                        AggregatedViews
                )
                SELECT day, language, platform_type, title, views
                FROM RankedViews
                WHERE rank_by_views <= {rank_by_views}
                ORDER BY day, language, title, platform_type
            """
        else:
            query = f"""
                SELECT
                    DATE(datehour) AS day,
                    REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') AS language,
                    CASE
                        WHEN REGEXP_CONTAINS(wiki, r'\.m$') THEN 'mobile'
                        ELSE 'desktop'
                    END AS platform_type,
                    title,
                    SUM(views) AS views
                FROM
                    `{table_id}`
                WHERE
                    {date_where_clause}
                    AND REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') IN ({lang_filter})
                    {automated_traffic_filter}
                GROUP BY 1, 2, 3, 4
                ORDER BY day, language, title, platform_type
            """

        try:
            query_job = client.query(query)
            
            # Se usa Dry Run para estimar el costo de la consulta
            # query_job = client.query(query, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
            # print(f"La consulta procesaría {query_job.total_bytes_processed / (1024**3):.2f} GB de datos")

            results = query_job.to_dataframe()
            all_data.append(results)

        except Exception as e:
            print(f"Error al ejecutar consulta BigQuery para {table_id}: {e}")
            raise

        current_year += 1

    if not all_data:
        return pd.DataFrame()

    final_df = pd.concat(all_data, ignore_index=True)

    df_daily_total = final_df.rename(columns={'views': 'views_total'}, inplace=False)

    return df_daily_total

def classify_page(title):
    title_lower = str(title).lower()
    
    if re.search(r'movie|film|actor|series|tv|netflix', title_lower):
        return 'Cine_TV'
    if re.search(r'software|program|ai|data|python|java', title_lower):
        return 'Tecnologia'
    if re.search(r'earthquake|physics|chemistry|space|science|astronomy', title_lower):
        return 'Ciencia'
    if re.search(r'sport|football|soccer|basket|world_cup', title_lower):
        return 'Deportes'
    
    return 'General'

def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        print("No hay datos, no se aplicarán transformaciones.")
        return df

    df = df.copy()    
    df_platform_agg = df.groupby(['day', 'language', 'title']).agg(
        views_total=('views_total', 'sum')
    ).reset_index()
    
    df = df_platform_agg.copy()
    df = df.sort_values(by=['language', 'title', 'day'])

    df['category'] = df['title'].apply(classify_page)
    df['original_title'] = df['title'].copy() 

    # Normalización del título para la dimensión dim_page
    df['title_normalized'] = df['title'].apply(normalize_string)    
    df['title_normalized'] = df['title_normalized'].str.lower().str.replace('_', ' ', regex=False)
    df['title_normalized'] = df['title_normalized'].str.replace(r'[^a-z0-9 ]', '', regex=True)
    df['title_normalized'] = df['title_normalized'].str.replace(r'\s+', '_', regex=True)
    df['title_normalized'] = df['title_normalized'].str.strip('_')
    df['title_normalized'] = df['title_normalized'].str.replace('\x00', '', regex=False).str.strip()
    df['title_normalized'] = df['title_normalized'].apply(lambda x: 'unknown_page' if len(x) == 0 else x) 
    df['title_normalized'] = df['title_normalized'].str.slice(0, 250)
    
    df_final_agg = df.groupby(['day', 'language', 'title_normalized']).agg(
        views_total=('views_total', 'sum'),
        category=('category', 'first'),
        original_title=('original_title', 'first') 
    ).reset_index()
    
    df = df_final_agg.copy()
    df = df.sort_values(by=['language', 'title_normalized', 'day'])
    
    # Cálculo de promedio móvil (7 días)
    df['avg_views_7d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=7, min_periods=1).mean()
    )
    
    # Cálculo de promedio móvil (28 días)
    df['avg_views_28d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).mean()
    )

    # Cálculo de variaciones (Crecimiento porcentual de las vistas de una página)
    df['previous_day_views'] = df.groupby(['language', 'title_normalized'])['views_total'].shift(1)
    df['variations'] = ((df['views_total'] - df['previous_day_views']) / df['previous_day_views']) * 100
    df['variations'] = df['variations'].replace([float('inf'), float('-inf')], 0) 
    df = df.drop(columns=['previous_day_views'])
    df['variations'] = df['variations'].fillna(0)

    # Cálculo de tendencias
    df['rolling_std_28d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).std()
    )
    
    # Z-score = (valor_actual - media_rolling) / desviacion_estandar_rolling
    std_col = df['rolling_std_28d']
    diff_col = df['views_total'] - df['avg_views_28d']
    
    # Manejo casos donde la desviación estándar es cero
    df['trend_score'] = np.where(
        std_col == 0,
        0, 
        diff_col / std_col
    )
    
    df['trend_score'] = df['trend_score'].fillna(0)

    df = df.drop(columns=['rolling_std_28d'])    
    return df

def load_data_to_postgres(df: pd.DataFrame):
    if df.empty:
        print("DataFrame vacío, no hay datos para cargar en PostgreSQL.")
        return

    conn = get_db_connection()
    if conn is None:
        raise Exception("Fallo al conectar a la base de datos para la carga.")

    try:
        cur = conn.cursor()
        
        conn.autocommit = False 
        
        # Proceso para dim_page
        df['title_normalized'] = df['title_normalized'].astype(str).str.strip()
        df['language'] = df['language'].astype(str).str.strip()
        df['original_title'] = df['original_title'].astype(str).str.strip()
        df['title_normalized'] = df['title_normalized'].str.replace('\x00', '', regex=False).str.strip()
        
        dim_page_data = df[['title_normalized', 'language', 'category', 'original_title']].drop_duplicates(
            subset=['title_normalized', 'language'], 
            keep='first'
        ).copy()
        
        dim_page_data = dim_page_data.reset_index(drop=True)
        num_keys = len(dim_page_data)
                
        insert_dim_page_query = """
            INSERT INTO dim_page (title_normalized, language, category, original_title)
            VALUES %s
            ON CONFLICT (title_normalized, language) DO UPDATE
            SET
                category = EXCLUDED.category,
                original_title = EXCLUDED.original_title,
                updated_at = NOW()
            RETURNING page_id, title_normalized AS title_normalized_db, language AS language_db;
        """
        
        all_inserted_pages = []

        for i in range(0, num_keys, DIM_BATCH_SIZE):
            chunk = dim_page_data.iloc[i:i + DIM_BATCH_SIZE]
            
            extras.execute_values(
                cur, 
                insert_dim_page_query, 
                chunk[['title_normalized', 'language', 'category', 'original_title']].values, 
                page_size=DIM_BATCH_SIZE
            ) 
            inserted_dim_pages = cur.fetchall()
            all_inserted_pages.extend(inserted_dim_pages)
        
        conn.commit()

        dim_page_map_df = pd.DataFrame(
            all_inserted_pages, 
            columns=['page_id', 'title_normalized_db', 'language_db']
        )
        
        dim_page_map_df['title_normalized_db'] = dim_page_map_df['title_normalized_db'].astype(str).str.strip()
        dim_page_map_df['language_db'] = dim_page_map_df['language_db'].astype(str).str.strip()
        dim_page_map_df['title_normalized_db'] = (
            dim_page_map_df['title_normalized_db']
            .str.replace('\x00', '', regex=False)
            .str.strip() 
        )
        
        df = pd.merge(
            df, 
            dim_page_map_df, 
            left_on=['title_normalized', 'language'],
            right_on=['title_normalized_db', 'language_db'],
            how='left'
        )

        if 'page_id' not in df.columns or df['page_id'].isnull().any():
            unmapped_rows = df[df['page_id'].isnull()]
            if not unmapped_rows.empty:
                print("\nERROR: Los siguientes datos no pudieron mapear el page_id:")
                print(unmapped_rows[['title_normalized', 'language']].drop_duplicates().head(5))
            
            raise Exception("Error al mapear page_id después del UPSERT de dim_page.")
        
        df.drop(columns=['title_normalized_db', 'language_db', 'title_normalized', 'category', 'original_title'], inplace=True, errors='ignore')

        # Proceso para fact_pageviews_daily
        fact_columns = [
            'day', 'page_id', 'language', 'views_total', 'avg_views_7d',
            'avg_views_28d', 'variations', 'trend_score'
        ]
        
        df['page_id'] = df['page_id'].astype(int)
        
        df_for_fact = df[fact_columns].copy()
        df_for_fact = df_for_fact.where(pd.notnull(df_for_fact), None)

        insert_fact_query = """
            INSERT INTO fact_pageviews_daily (
                day, page_id, language, views_total, avg_views_7d, avg_views_28d, variations, trend_score
            )
            VALUES %s
            ON CONFLICT (day, page_id, language) DO UPDATE SET
                views_total = EXCLUDED.views_total,
                avg_views_7d = EXCLUDED.avg_views_7d,
                avg_views_28d = EXCLUDED.avg_views_28d,
                variations = EXCLUDED.variations,
                trend_score = EXCLUDED.trend_score,
                updated_at = NOW();
        """
        
        extras.execute_values(cur, insert_fact_query, df_for_fact.values, page_size=2000)
        conn.commit()

    except (Exception, psycopg2.Error) as error:
        print(f"Error durante la carga de datos en PostgreSQL: {error}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            cur.close()
            conn.close()

def refresh_materialized_views():
    conn = get_db_connection()
    if conn is None:
        raise Exception("Fallo al conectar a la base de datos para la carga.")
    try:
        cur = conn.cursor()

        cur.execute("REFRESH MATERIALIZED VIEW mv_top_n_daily_by_language;")
        cur.execute("REFRESH MATERIALIZED VIEW mv_trending_daily;")
        conn.commit()

    except (Exception, psycopg2.Error) as error:
        print(f"Error al refrescar vistas materializadas: {error}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            cur.close()
            conn.close()

def run_etl():
    start_date_str = "2023-12-26"
    end_date_str = "2024-01-01"
    languages_to_extract = ["en", "es"]
    exclude_bots = True
    rank_by_views = 5000
    worker_id = "local-dev-worker"
    job_id = None

    job_id = register_etl_job_start(start_date_str, end_date_str, languages_to_extract, worker_id)
    if not job_id:
        print("Fallo crítico: No se pudo registrar el Job, abortando ETL.")
        sys.exit(1)

    try:
        start_date_dt = datetime.strptime(start_date_str, "%Y-%m-%d")
        end_date_dt = datetime.strptime(end_date_str, "%Y-%m-%d")
        bq_client = get_bigquery_client()
        extracted_data = extract_pageviews(
            bq_client,
            start_date_dt,
            end_date_dt,
            languages_to_extract,
            rank_by_views,
            exclude_bots
        )

        if extracted_data.empty:
            print("\nNo se extrajeron datos para los parámetros proporcionados. No hay datos para transformar.")
            return

        transformed_data = transform_data(extracted_data)
        load_data_to_postgres(transformed_data)
        refresh_materialized_views()
        print(f"El proceso de carga a base de datos se completó con éxito.")

    except Exception as e:
        import traceback
        print(f"El proceso falló con una excepción:")
        traceback.print_exc()
        exit(1)


if __name__ == "__main__":
    run_etl()
