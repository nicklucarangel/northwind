import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv("PGHOST"),
    port=os.getenv("PGPORT"),
    dbname=os.getenv("PGDATABASE"),
    user=os.getenv("PGUSER"),
    password=os.getenv("PGPASSWORD"),
)

conn.autocommit = True

with conn.cursor() as cur:
    cur.execute("create schema if not exists raw;")
    cur.execute("create schema if not exists analytics;")

print("Schemas criados com sucesso.")

conn.close()