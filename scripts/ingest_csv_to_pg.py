import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()

def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Variável de ambiente obrigatória não definida: {name}")
    return value

DB_HOST = os.getenv("PGHOST", "localhost")
DB_PORT = os.getenv("PGPORT", "5432")
DB_NAME = require_env("PGDATABASE")
DB_USER = require_env("PGUSER")
DB_PASS = require_env("PGPASSWORD")

DATA_DIR = Path("data/normalized")

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

TABLE_CONFIG = {
    "categories.csv": "categories",
    "customer_customer_demo.csv": "customer_customer_demo",
    "customer_demographics.csv": "customer_demographics",
    "customers.csv": "customers",
    "employee_territories.csv": "employee_territories",
    "employees.csv": "employees",
    "order_details.csv": "order_details",
    "orders.csv": "orders",
    "products.csv": "products",
    "region.csv": "region",
    "shippers.csv": "shippers",
    "suppliers.csv": "suppliers",
    "territories.csv": "territories",
    "us_states.csv": "us_states",
}

def load_csv_to_postgres(csv_file: Path, table_name: str) -> None:
    print(f"Carregando {csv_file.name} -> raw.{table_name}")
    df = pd.read_csv(csv_file, sep=";")

    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=1000,
    )

    print(f"OK: raw.{table_name} carregada com {len(df)} linhas.")

def main():
    if not DATA_DIR.exists():
        raise FileNotFoundError(f"Pasta não encontrada: {DATA_DIR}")

    for filename, table_name in TABLE_CONFIG.items():
        file_path = DATA_DIR / filename

        if not file_path.exists():
            print(f"Arquivo não encontrado, pulando: {file_path}")
            continue

        load_csv_to_postgres(file_path, table_name)

    print("Carga concluída.")

if __name__ == "__main__":
    main()