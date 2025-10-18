import os
from datetime import datetime
from google.cloud import bigquery
import pandas as pd
import unicodedata

BIGQUERY_PROJECT_ID = os.getenv("BIGQUERY_PROJECT_ID", "disagro-hr-test")
PUBLIC_DATA_ID = "bigquery-public-data"
BIGQUERY_DATASET = "wikipedia"
BIGQUERY_TABLE_PREFIX = "pageviews_"

def get_bigquery_client():
    try:
        client = bigquery.Client(project=BIGQUERY_PROJECT_ID)
        return client
    except Exception as e:
        print(f"Error al inicializar cliente de BigQuery: {e}")
        raise

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

def normalize_string(text):
    if pd.isna(text):
        return text
    
    normalized = unicodedata.normalize('NFD', str(text))
    cleaned = ''.join(c for c in normalized if unicodedata.category(c) != 'Mn')
    return cleaned

def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        print("No hay datos, no se aplicarán transformaciones.")
        return df

    df = df.copy()
    df = df.sort_values(by=['language', 'title', 'platform_type', 'day'])

    # Normalización del título para la dimensión dim_page
    df['normalized_title'] = df['title'].apply(normalize_string)
    df['normalized_title'] = df['normalized_title'].str.lower()
    df['normalized_title'] = df['normalized_title'].str.replace(' ', '_', regex=False)

    # Cálculo de promedio móvil (7 días)
    df['avg_views_7d'] = df.groupby(['language', 'title', 'platform_type'])['views_total'].transform(
        lambda x: x.rolling(window=7, min_periods=1).mean()
    )
    
    # Cálculo de promedio móvil (28 días)
    df['avg_views_28d'] = df.groupby(['language', 'title', 'platform_type'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).mean()
    )

    # Cálculo de variaciones (Crecimiento porcentual de las vistas de una página)
    df['previous_day_views'] = df.groupby(['language', 'title', 'platform_type'])['views_total'].shift(1)
    df['variations'] = ((df['views_total'] - df['previous_day_views']) / df['previous_day_views']) * 100
    df['variations'] = df['variations'].replace([float('inf'), float('-inf')], 0) 
    df = df.drop(columns=['previous_day_views'])
    df['variations'] = df['variations'].fillna(0)

    # Cálculo de tendencias
    df['rolling_std_28d'] = df.groupby(['language', 'title', 'platform_type'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).std()
    )
    
    # Z-score = (valor_actual - media_rolling) / desviacion_estandar_rolling
    df['trend_score'] = (df['views_total'] - df['avg_views_28d']) / df['rolling_std_28d']

    # Manejo casos donde la desviación estándar es cero
    df['trend_score'] = df['trend_score'].replace([float('inf'), float('-inf')], 0)
    df['trend_score'] = df['trend_score'].fillna(0)

    df = df.drop(columns=['rolling_std_28d'])

    return df

def run_etl():
    start_date_str = "2023-12-26"
    end_date_str = "2024-01-01"
    languages_to_extract = ["en", "es"]
    exclude_bots = True
    rank_by_views = 5000

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

        print(extracted_data.head())
        transformed_data = transform_data(extracted_data)
        print(transformed_data.head())

    except Exception as e:
        import traceback
        print(f"El proceso falló con una excepción:")
        traceback.print_exc()
        exit(1)


if __name__ == "__main__":
    run_etl()