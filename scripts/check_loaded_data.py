import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('PGUSER')}:{os.getenv('PGPASSWORD')}"
    f"@{os.getenv('PGHOST')}:{os.getenv('PGPORT')}/{os.getenv('PGDATABASE')}"
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