import os
from datetime import datetime
from google.cloud import bigquery
import pandas as pd

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
            """        

        query = f"""
            SELECT
                DATE(datehour) AS day,
                REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') AS language,
                CASE
                    WHEN REGEXP_CONTAINS(wiki, r'\.m$') THEN 'mobile'
                    ELSE 'desktop'
                END AS platform_type,
                title,
                SUM(views) AS views_total
            FROM
                `{table_id}`
            WHERE
                {date_where_clause}
                AND REGEXP_EXTRACT(wiki, r'^([a-z]{{2}})') IN ({lang_filter})
                {automated_traffic_filter}
            GROUP BY 1, 2, 3, 4
            ORDER BY day, language, title
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

    df_daily_total = final_df.groupby(['day', 'language', 'title']).agg(
        views_total_unified=('views_total', 'sum')
    ).reset_index()
    
    df_daily_total.rename(columns={'views_total_unified': 'views_total'}, inplace=True)
    
    return df_daily_total

def run_etl():
    start_date_str = "2024-01-01"
    end_date_str = "2024-01-01"
    languages_to_extract = ["en", "es"]
    exclude_bots = True

    try:
        start_date_dt = datetime.strptime(start_date_str, "%Y-%m-%d")
        end_date_dt = datetime.strptime(end_date_str, "%Y-%m-%d")
        bq_client = get_bigquery_client()
        extracted_data = extract_pageviews(
            bq_client,
            start_date_dt,
            end_date_dt,
            languages_to_extract,
            exclude_bots
        )

        if not extracted_data.empty:
            print(extracted_data.head())
        else:
            print("\nNo se extrajeron datos para los parámetros proporcionados.")

    except Exception as e:
        print(f"El proceso de extracción falló: {e}")
        exit(1)


if __name__ == "__main__":
    run_etl()