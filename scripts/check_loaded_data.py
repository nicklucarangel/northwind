import os
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from dotenv import load_dotenv

load_dotenv()

def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Variavel de ambiente obrigatoria nao definida: {name}")
    return value

DB_HOST = os.getenv("PGHOST", "localhost")
DB_PORT = os.getenv("PGPORT", "5432")
DB_NAME = require_env("PGDATABASE")
DB_USER = require_env("PGUSER")
DB_PASS = require_env("PGPASSWORD")

engine = create_engine(
    URL.create(
        drivername="postgresql+psycopg2",
        username=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=int(DB_PORT),
        database=DB_NAME,
    )
)

tables = [
    "categories",
    "customer_customer_demo",
    "customer_demographics",
    "customers",
    "employee_territories",
    "employees",
    "order_details",
    "orders",
    "products",
    "region",
    "shippers",
    "suppliers",
    "territories",
    "us_states",
]

with engine.connect() as conn:
    for table in tables:
        result = conn.execute(
            text(f"select count(*) as row_count from raw.{table}")
        ).fetchone()
        print(f"raw.{table}: {result.row_count} linhas")
