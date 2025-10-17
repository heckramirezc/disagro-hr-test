FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
# COPY . /app/etl/
# COPY ../run_etl.py /app/

CMD python connect_db.py

# CMD ["python", "connect_db.py"] # Por ahora, usamos este para probar la conexión
# CMD ["python", "run_etl.py"]

