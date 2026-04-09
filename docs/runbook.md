# Runbook

## Purpose

This runbook describes how to execute the `northwind-analytics` project end-to-end, from environment setup and CSV loading into PostgreSQL to dbt transformations and Power BI dashboard refresh.

Summary flow:

1. Start PostgreSQL with Docker Compose
2. Normalize the CSV files
3. Create the database schemas
4. Load the data into `raw`
5. Run dbt transformations and tests
6. Refresh `powerbi/northwind.pbix`

## Prerequisites

- Windows with PowerShell
- Docker Desktop running
- Python available in the local `.venv` virtual environment
- PostgreSQL exposed on port `5432`

Configuration files already available in the project:

- `.env`
- `docker-compose.yml`
- `dbt/profiles.yml`

Expected variables in `.env`:

```env
PGHOST=localhost
PGPORT=5432
PGDATABASE=*******
PGUSER=*******
PGPASSWORD=*******
```

## Relevant structure

- `data/input/extracted/`: original CSV files extracted from the Northwind package
- `data/normalized/`: normalized CSV files ready for ingestion
- `scripts/normalize_csv.py`: cleans line breaks and standardizes files
- `scripts/create_schemas.py`: creates the `raw` and `analytics` schemas
- `scripts/ingest_csv_to_pg.py`: loads normalized CSVs into `raw`
- `scripts/check_loaded_data.py`: validates loaded table row counts
- `dbt/`: dbt project with staging, intermediate, and marts layers
- `powerbi/northwind.pbix`: final dashboard

## End-to-end execution

### 1. Start the database

From the project root:

```powershell
docker compose up -d
```

To verify the container is healthy:

```powershell
docker compose ps
```

Expected container: `northwind_pg`

### 2. Activate the virtual environment

```powershell
.\.venv\Scripts\Activate.ps1
```

If preferred, the commands below can also be executed without activating the environment by calling the binaries directly from `.venv\Scripts`.

### 3. Normalize the CSV files

```powershell
.\.venv\Scripts\python.exe scripts\normalize_csv.py
```

Expected result:

- files generated in `data/normalized/`
- logs following the pattern `OK <file> -> <file>.csv | rows=<n> cols=<n>`

### 4. Create the PostgreSQL schemas

```powershell
.\.venv\Scripts\python.exe scripts\create_schemas.py
```

Expected result:

```text
Schemas created successfully.
```

Created schemas:

- `raw`
- `analytics`

### 5. Load the data into `raw`

```powershell
.\.venv\Scripts\python.exe scripts\ingest_csv_to_pg.py
```

Expected behavior:

- each CSV in `data/normalized/` is loaded with `if_exists='replace'`
- tables are recreated in the `raw` schema

### 6. Validate the load

```powershell
.\.venv\Scripts\python.exe scripts\check_loaded_data.py
```

Row counts observed in this project environment:

```text
raw.categories: 8 rows
raw.customer_customer_demo: 0 rows
raw.customer_demographics: 0 rows
raw.customers: 91 rows
raw.employee_territories: 49 rows
raw.employees: 9 rows
raw.order_details: 2155 rows
raw.orders: 830 rows
raw.products: 77 rows
raw.region: 4 rows
raw.shippers: 6 rows
raw.suppliers: 29 rows
raw.territories: 53 rows
raw.us_states: 51 rows
```

Note:

- `customer_customer_demo` and `customer_demographics` are empty in the current load; this does not indicate a failure by itself.

### 7. Run dbt transformations

Inside the `dbt/` folder:

```powershell
cd dbt
..\.venv\Scripts\dbt.exe run
```

Alternatively, from the project root:

```powershell
Set-Location dbt
..\.venv\Scripts\dbt.exe run
```

Validated project binary:

```powershell
..\.venv\Scripts\dbt.exe
```

Models identified in the project:

- 25 models
- 82 tests
- 14 sources

Main analytical outputs:

- `analytics.fct_orders`
- `analytics.fct_order_lines`
- `analytics.dim_customers`
- `analytics.dim_products`
- `analytics.dim_employees`
- `analytics.dim_shippers`
- `analytics.agg_sales_monthly`
- `analytics.agg_sales_by_product`
- `analytics.agg_sales_by_category`
- `analytics.agg_customer_behavior`
- `analytics.agg_customer_churn_risk`
- `analytics.agg_shipping_performance`

### 8. Run dbt tests

Still inside the `dbt/` folder:

```powershell
..\.venv\Scripts\dbt.exe test --select dim_customers dim_products dim_employees dim_shippers fct_order_lines fct_orders
```

Validated result in this environment:

- `not_null` and `unique` tests passed for the main dimensions and fact tables

### 9. Refresh Power BI

Open:

- `powerbi/northwind.pbix`

In Power BI Desktop:

1. Refresh the PostgreSQL data sources connected to `northwind`
2. Reload datasets from the `analytics` schema
3. Validate that the main analytical tables are available
4. Save the final version of the dashboard

If needed, export the final material to PDF from Power BI.

## Quick validation queries

After running the transformation layer, validate a few PostgreSQL tables:

```sql
select count(*) from analytics.fct_orders;
select count(*) from analytics.fct_order_lines;
select count(*) from analytics.dim_customers;
select count(*) from analytics.agg_sales_monthly;
```

Check a sample of orders:

```sql
select *
from analytics.fct_orders
order by order_date desc
limit 10;
```

Check churn distribution:

```sql
select churn_risk_status, count(*)
from analytics.agg_customer_churn_risk
group by 1
order by 1;
```

## Done criteria

The pipeline can be considered complete when:

- the PostgreSQL container is running
- normalized files exist in `data/normalized/`
- tables in the `raw` schema have been loaded
- models in the `analytics` schema have been materialized
- the main dbt tests have passed
- `powerbi/northwind.pbix` has been refreshed with data from the analytical schema
