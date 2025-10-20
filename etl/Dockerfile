FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir etl
COPY . /app/etl/
ENV PYTHONPATH=/app:$PYTHONPATH
COPY bigquery_key.json /app/bigquery_key.json
CMD python /app/etl/main_etl.py
