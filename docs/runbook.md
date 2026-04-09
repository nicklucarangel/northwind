# Runbook

## Objetivo

Este runbook descreve como executar o pipeline end-to-end do projeto `northwind-analytics`, desde a preparação do ambiente e carga dos CSVs no PostgreSQL até a transformação com dbt e atualização do dashboard no Power BI.

Fluxo resumido:

1. Subir o PostgreSQL com Docker Compose
2. Normalizar os arquivos CSV
3. Criar os schemas do banco
4. Carregar os dados em `raw`
5. Executar transformações e testes no dbt
6. Atualizar o arquivo `powerbi/northwind.pbix`

## Pré-requisitos

- Windows com PowerShell
- Docker Desktop em execução
- Python disponível no ambiente virtual local `.venv`
- PostgreSQL exposto na porta `5432`

Arquivos de configuração já existentes no projeto:

- `.env`
- `docker-compose.yml`
- `dbt/profiles.yml`

Variáveis esperadas no `.env`:

```env
PGHOST=localhost
PGPORT=5432
PGDATABASE=*******
PGUSER=*******
PGPASSWORD=*******
```

## Estrutura relevante

- `data/input/extracted/`: CSVs originais extraídos do pacote Northwind
- `data/normalized/`: CSVs normalizados para ingestão
- `scripts/normalize_csv.py`: higieniza quebras de linha e padroniza arquivos
- `scripts/create_schemas.py`: cria os schemas `raw` e `analytics`
- `scripts/ingest_csv_to_pg.py`: carrega os CSVs normalizados em `raw`
- `scripts/check_loaded_data.py`: valida contagem das tabelas carregadas
- `dbt/`: projeto dbt com camadas staging, intermediate e marts
- `powerbi/northwind.pbix`: dashboard final

## Execução end-to-end

### 1. Subir o banco

Na raiz do projeto:

```powershell
docker compose up -d
```

Para verificar se o container está saudável:

```powershell
docker compose ps
```

Container esperado: `northwind_pg`

### 2. Ativar o ambiente virtual

```powershell
.\.venv\Scripts\Activate.ps1
```

Se preferir, os comandos abaixo também podem ser executados sem ativar o ambiente, chamando os binários diretamente em `.venv\Scripts`.

### 3. Normalizar os CSVs

```powershell
.\.venv\Scripts\python.exe scripts\normalize_csv.py
```

Resultado esperado:

- arquivos gerados em `data/normalized/`
- logs com padrão `OK <arquivo> -> <arquivo>.csv | linhas=<n> cols=<n>`

### 4. Criar os schemas no PostgreSQL

```powershell
.\.venv\Scripts\python.exe scripts\create_schemas.py
```

Resultado esperado:

```text
Schemas criados com sucesso.
```

Schemas criados:

- `raw`
- `analytics`

### 5. Ingerir os dados em `raw`

```powershell
.\.venv\Scripts\python.exe scripts\ingest_csv_to_pg.py
```

Comportamento esperado:

- cada CSV de `data/normalized/` é carregado com `if_exists='replace'`
- as tabelas são recriadas no schema `raw`

### 6. Validar a carga

```powershell
.\.venv\Scripts\python.exe scripts\check_loaded_data.py
```

Contagens observadas no ambiente deste projeto:

```text
raw.categories: 8 linhas
raw.customer_customer_demo: 0 linhas
raw.customer_demographics: 0 linhas
raw.customers: 91 linhas
raw.employee_territories: 49 linhas
raw.employees: 9 linhas
raw.order_details: 2155 linhas
raw.orders: 830 linhas
raw.products: 77 linhas
raw.region: 4 linhas
raw.shippers: 6 linhas
raw.suppliers: 29 linhas
raw.territories: 53 linhas
raw.us_states: 51 linhas
```

Observação:

- `customer_customer_demo` e `customer_demographics` estão vazias na carga atual; isso não indica falha por si só.

### 7. Executar transformações dbt

Na pasta `dbt/`:

```powershell
cd dbt
..\.venv\Scripts\dbt.exe run
```

Se o PowerShell interpretar mal o caminho por causa do espaço acidental, use exatamente:

```powershell
..\.venv\Scripts\dbt.exe run
```

Ou, de forma mais segura, a partir da raiz:

```powershell
Set-Location dbt
..\.venv\Scripts\dbt.exe run
```

Binário validado no projeto:

```powershell
..\.venv\Scripts\dbt.exe
```

Modelos identificados no projeto:

- 25 modelos
- 82 testes
- 14 sources

Principais saídas analíticas:

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

### 8. Executar testes dbt

Ainda na pasta `dbt/`:

```powershell
..\.venv\Scripts\dbt.exe test --select dim_customers dim_products dim_employees dim_shippers fct_order_lines fct_orders
```

Resultado validado no ambiente:

- testes de `not_null` e `unique` executaram com sucesso para as principais dimensões e fatos

### 9. Atualizar o Power BI

Abrir:

- `powerbi/northwind.pbix`

No Power BI Desktop:

1. Atualizar as fontes conectadas ao PostgreSQL `northwind`
2. Recarregar os datasets a partir do schema `analytics`
3. Validar se as tabelas analíticas principais estão disponíveis
4. Salvar a versão final do dashboard

Se necessário, exportar o material final para PDF a partir do Power BI.

## Consultas rápidas de validação

Após rodar a transformação, validar algumas tabelas no PostgreSQL:

```sql
select count(*) from analytics.fct_orders;
select count(*) from analytics.fct_order_lines;
select count(*) from analytics.dim_customers;
select count(*) from analytics.agg_sales_monthly;
```

Verificar amostra de pedidos:

```sql
select *
from analytics.fct_orders
order by order_date desc
limit 10;
```

Verificar churn:

```sql
select churn_risk_status, count(*)
from analytics.agg_customer_churn_risk
group by 1
order by 1;
```

## Troubleshooting

### Docker sem permissão ou daemon indisponível

Sintoma:

- erro ao executar `docker compose ps` ou `docker compose up -d`

Ação:

- confirmar que o Docker Desktop está aberto
- confirmar que o engine Linux está rodando
- reexecutar os comandos no PowerShell com acesso ao Docker

### `dbt` não reconhecido

Sintoma:

- `dbt` não encontrado no PATH

Ação:

- usar o executável local do projeto:

```powershell
C:\Users\nicolas.rangel_pier\Desktop\Nico\northwind-analytics\.venv\Scripts\dbt.exe
```

### `python` não reconhecido

Sintoma:

- alias do Windows aponta para a Microsoft Store

Ação:

- usar o Python local do ambiente virtual:

```powershell
C:\Users\nicolas.rangel_pier\Desktop\Nico\northwind-analytics\.venv\Scripts\python.exe
```

### `dbt build` falha com `[WinError 5] Acesso negado`

Observação do ambiente atual:

- `dbt ls` funcionou
- `dbt test` funcionou
- `dbt build` falhou com `[WinError 5] Acesso negado` ao criar recursos internos de multiprocessing no Windows

Ação recomendada:

- executar `dbt run` e `dbt test` separadamente
- manter o registro do erro caso seja necessário ajustar permissões do ambiente

## Critério de pronto

O pipeline pode ser considerado concluído quando:

- o container PostgreSQL está em execução
- os arquivos normalizados existem em `data/normalized/`
- as tabelas do schema `raw` foram carregadas
- os modelos do schema `analytics` foram materializados
- os testes dbt principais passaram
- o arquivo `powerbi/northwind.pbix` foi atualizado com dados do schema analítico
