FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY bigquery_key.json /app/bigquery_key.json
# COPY . /app/etl/
# COPY ../run_etl.py /app/

CMD python main_etl.py
# CMD python connect_db.py
# CMD ["python", "run_etl.py"]

