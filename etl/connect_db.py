import os
import psycopg2
import time

def test_db_connection():
    # Obtener variables de Neon inyectadas por Docker Compose
    HOST = os.getenv('DB_HOST')
    USER = os.getenv('DB_USER')
    PASSWORD = os.getenv('DB_PASSWORD')
    NAME = os.getenv('DB_NAME')
    SSLMODE = os.getenv('DB_SSLMODE', 'require') # Neon requiere SSL

    if not HOST:
        print("Error: La variable de entorno HOST no está configurada para el ETL.")
        return

    print("ETL Service: Esperando que la base de datos esté lista...")
    time.sleep(10)

    print(f"ETL Service: Intentando conectar a PostgreSQL usando: {HOST}...")

    try:
        conn = psycopg2.connect(
            host=HOST,
            user=USER,
            password=PASSWORD,
            dbname=NAME,
            sslmode=SSLMODE,
            connect_timeout=10
        )
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
