import os
from google.cloud import bigquery

BIGQUERY_PROJECT_ID = os.getenv("BIGQUERY_PROJECT_ID", "bigquery-public-data")
BIGQUERY_DATASET = "wikipedia"

def get_bigquery_client():
    try:
        client = bigquery.Client(project=BIGQUERY_PROJECT_ID)
        
        print(f"Cliente BigQuery inicializado para el proyecto: {BIGQUERY_PROJECT_ID}")
        client.query("SELECT 1").result()
        print("Prueba de conexión a BigQuery exitosa.")
        
        return client
    except Exception as e:
        print(f"Error al inicializar o probar la conexión a BigQuery. Error: {e}")
        raise

def run_etl_logic():
    try:
        bq_client = get_bigquery_client()
        print("main_etl.py finalizado correctamente.")

    except Exception as e:
        exit(1)


if __name__ == "__main__":
    run_etl_logic()