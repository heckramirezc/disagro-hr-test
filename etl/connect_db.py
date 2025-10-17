import os
import psycopg2
import time

def test_db_connection():
    db_url = os.getenv("DATABASE_URL")

    if not db_url:
        print("Error: La variable de entorno DATABASE_URL no está configurada para el ETL.")
        return

    print("ETL Service: Esperando que la base de datos esté lista...")
    time.sleep(10)

    print(f"ETL Service: Intentando conectar a PostgreSQL usando: {db_url.split('@')[-1] if '@' in db_url else db_url}...")

    try:
        conn = psycopg2.connect(db_url)
        cursor = conn.cursor()

        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()

        print(f"ETL Service: Conexión exitosa a PostgreSQL. Versión de la base de datos: {db_version[0]}")

        cursor.close()
        conn.close()

    except psycopg2.Error as e:
        print(f"ETL Service: Error al conectar a la base de datos: {e}")
    except Exception as e:
        print(f"ETL Service: Un error inesperado ocurrió: {e}")

if __name__ == "__main__":
    test_db_connection()
