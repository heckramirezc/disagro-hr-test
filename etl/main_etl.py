import os
from google.cloud import bigquery

BIGQUERY_PROJECT_ID = os.getenv("BIGQUERY_PROJECT_ID", "disagro-hr-test")

def get_bigquery_client():
    try:
        client = bigquery.Client(project=BIGQUERY_PROJECT_ID)
        
        print(f"Cliente BigQuery inicializado para el proyecto: {BIGQUERY_PROJECT_ID}")

        PUBLIC_DATA_ID = "bigquery-public-data"
        WIKIPEDIA_DATASET = "wikipedia"
        WIKIPEDIA_TABLE = "pageviews_2020"

        query = f"""
        SELECT title, SUM(views) AS total_views
        FROM `{PUBLIC_DATA_ID}.{WIKIPEDIA_DATASET}.{WIKIPEDIA_TABLE}`
        WHERE wiki = 'en'
        AND datehour >= '2020-01-01 00:00:00' 
        AND datehour < '2020-01-01 01:00:00'
        GROUP BY title
        ORDER BY total_views DESC
        LIMIT 5
        """
        
        results = client.query(query).result()
        
        print("Prueba de conexión a BigQuery exitosa.")
        print(f"Resultados de Wikipedia (primeras {results.total_rows} filas):")
        for row in results:
            print(f"  > Título: {row.title}, Vistas: {row.total_views}")
        
        return client
    except Exception as e:
        print(f"Error al inicializar o probar la conexión a BigQuery. Error: {e}")
        raise

def run_etl_logic():
    """Función que encapsula el flujo de trabajo ETL."""
    try:
        bq_client = get_bigquery_client()
        print("main_etl.py finalizado correctamente.")

    except Exception as e:
        exit(1)


if __name__ == "__main__":
    run_etl_logic()