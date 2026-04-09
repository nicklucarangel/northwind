# Data Dictionary

## Overview

This document describes the datasets, structure, and business logic used in the Northwind Analytics project.

The project follows a layered architecture:

- **raw**: source data ingested from CSV files with minimal transformation
- **staging**: cleaned and standardized tables
- **intermediate**: enriched, business-oriented transformations
- **marts**: final analytical models used for reporting and dashboards

All financial metrics are derived from transactional data and reflect values at the time of the order.

---

## Grain Reference

| Model | Grain |
|------|-------|
| stg_erp__orders | 1 row per order |
| stg_erp__order_details | 1 row per order line |
| int_sales__order_lines | 1 row per order line |
| int_sales__orders_enriched | 1 row per order |
| dim_products | 1 row per product |
| dim_customers | 1 row per customer |
| dim_employees | 1 row per employee |
| dim_shippers | 1 row per shipper |
| fct_order_lines | 1 row per order line |
| fct_orders | 1 row per order |
| agg_sales_monthly | 1 row per month |
| agg_sales_by_product | 1 row per product |
| agg_sales_by_category | 1 row per category |
| agg_customer_behavior | 1 row per customer |
| agg_customer_churn_risk | 1 row per customer |

---

## Source Layer (raw)

| Table | Description | Grain |
|------|-------------|-------|
| raw.orders | Order header data from ERP | 1 row per order |
| raw.order_details | Order item data | 1 row per order line |
| raw.customers | Customer master data | 1 row per customer |
| raw.products | Product master data | 1 row per product |
| raw.categories | Product category lookup | 1 row per category |
| raw.employees | Employee master data | 1 row per employee |
| raw.shippers | Shipping providers | 1 row per shipper |
| raw.suppliers | Supplier master data | 1 row per supplier |

---

## Staging Layer

### stg_erp__orders
**Description:** Cleaned and standardized order header data  
**Grain:** 1 row per order

| Column | Description |
|--------|-------------|
| order_id | Unique order identifier |
| customer_id | Customer identifier |
| employee_id | Employee responsible for the order |
| order_date | Order creation date |
| required_date | Required delivery date |
| shipped_date | Actual shipping date |
| shipper_id | Shipping provider |
| freight_amount | Freight cost |
| ship_city | Destination city |
| ship_country | Destination country |

---

### stg_erp__order_details
**Description:** Cleaned order line data  
**Grain:** 1 row per order line

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| product_id | Product identifier |
| unit_price | Price per unit |
| quantity | Quantity ordered |
| discount | Discount applied |

### stg_erp__categories
**Description:** Cleaned and standardized product category data  
**Grain:** 1 row per category

| Column | Description |
|--------|-------------|
| category_id | Unique category identifier |
| category_name | Name of the category |
| description | Description of the category |

### stg_erp__customers
**Description:** Cleaned and standardized customer master data  
**Grain:** 1 row per customer

| Column | Description |
|--------|-------------|
| customer_id | Unique customer identifier |
| company_name | Name of the customer company |
| contact_name | Name of the primary contact |
| contact_title | Job title of the primary contact |
| address | Customer address |
| city | Customer city |
| region | Customer region or state |
| postal_code | Customer postal code |
| country | Customer country |
| phone | Customer phone number |
| fax | Customer fax number |
| phone_clean | Customer phone number containing only digits |
| fax_clean | Customer fax number containing only digits |

### stg_erp__employees
**Description:** Cleaned and standardized employee master data  
**Grain:** 1 row per employee

| Column | Description |
|--------|-------------|
| employee_id | Unique employee identifier |
| last_name | Employee last name |
| first_name | Employee first name |
| employee_full_name | Full name of the employee |
| title | Employee job title |
| title_of_courtesy | Courtesy title of the employee |
| birth_date | Employee date of birth |
| hire_date | Employee hiring date |
| address | Employee address |
| city | Employee city |
| region | Employee region or state |
| postal_code | Employee postal code |
| country | Employee country |
| home_phone_raw | Employee home phone number (original format) |
| home_phone_clean | Employee home phone number containing only digits |
| extension | Employee phone extension |
| notes | Additional notes about the employee |
| reports_to_employee_id | Identifier of the employee's manager |
| photo_path | Path to the employee photo |

### stg_erp__products
**Description:** Cleaned and standardized product master data  
**Grain:** 1 row per product

| Column | Description |
|--------|-------------|
| product_id | Unique product identifier |
| product_name | Name of the product |
| supplier_id | Identifier of the product supplier |
| category_id | Identifier of the product category |
| quantity_per_unit | Quantity per unit description |
| unit_price | Price per unit of the product |
| units_in_stock | Number of units available in stock |
| units_on_order | Number of units currently on order |
| reorder_level | Stock level at which reordering is triggered |
| is_discontinued | Indicates whether the product is discontinued |

### stg_erp__region
**Description:** Cleaned and standardized geographic region data  
**Grain:** 1 row per region

| Column | Description |
|--------|-------------|
| region_id | Unique region identifier |
| region_description | Description of the region |

### stg_erp__shippers
**Description:** Cleaned and standardized shipping provider data  
**Grain:** 1 row per shipper

| Column | Description |
|--------|-------------|
| shipper_id | Unique shipping provider identifier |
| shipper_name | Name of the shipping provider |
| phone_raw | Shipping provider phone number (original format) |
| phone_clean | Shipping provider phone number containing only digits |

### stg_erp__suppliers
**Description:** Cleaned and standardized supplier master data  
**Grain:** 1 row per supplier

| Column | Description |
|--------|-------------|
| supplier_id | Unique supplier identifier |
| supplier_name | Name of the supplier company |
| contact_name | Name of the primary contact |
| contact_title | Job title of the primary contact |
| address | Supplier address |
| city | Supplier city |
| region | Supplier region or state |
| postal_code | Supplier postal code |
| country | Supplier country |
| phone_raw | Supplier phone number (original format) |
| phone_clean | Supplier phone number containing only digits |
| fax_raw | Supplier fax number (original format) |
| fax_clean | Supplier fax number containing only digits |
| homepage | Supplier website URL |

### stg_erp__territories
**Description:** Cleaned and standardized sales territory data  
**Grain:** 1 row per territory

| Column | Description |
|--------|-------------|
| territory_id | Unique territory identifier |
| territory_description | Description of the territory |
| region_id | Identifier of the associated region |

### stg_erp__us_states
**Description:** Cleaned and standardized U.S. state reference data  
**Grain:** 1 row per state

| Column | Description |
|--------|-------------|
| state_id | Unique state identifier |
| state_name | Name of the state |
| state_abbr | Standard abbreviation of the state |
| state_region | Geographic region of the state |
---

## Intermediate Layer

### int_sales__order_lines
**Description:** Enriched sales line table  
**Grain:** 1 row per order line

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| customer_id | Customer identifier |
| product_id | Product identifier |
| category_id | Category identifier |
| quantity | Quantity sold |
| unit_price | Unit price |
| discount | Discount applied |
| gross_item_revenue | Unit price × quantity |
| net_item_revenue | Revenue after discount |
| discount_amount | Discount value |

---

### int_sales__orders_enriched
**Description:** Aggregated order-level metrics  
**Grain:** 1 row per order

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| customer_id | Customer identifier |
| order_date | Order date |
| total_quantity | Total items in order |
| gross_order_revenue | Total gross revenue |
| net_order_revenue | Revenue after discounts |
| total_discount_amount | Total discount applied |
| avg_discount_rate | Discount percentage |
| days_to_ship | Days between order and shipment |
| shipped_on_time_flag | Delivery performance indicator |

---

## Mart Layer

### fct_orders
**Description:** Core fact table for order-level analysis  
**Grain:** 1 row per order

---

### fct_order_lines
**Description:** Core fact table for detailed sales analysis  
**Grain:** 1 row per order line

---

### dim_products
**Description:** Product dimension with category and supplier info  
**Grain:** 1 row per product

---

### dim_customers
**Description:** Customer dimension  
**Grain:** 1 row per customer

---

### dim_employees
**Description:** Employee dimension  
**Grain:** 1 row per employee

---

### dim_shippers
**Description:** Shipping providers dimension  
**Grain:** 1 row per shipper

---

## Aggregated Models

### agg_sales_monthly
**Description:** Monthly sales summary  
**Grain:** 1 row per month

Key metrics:
- total_orders
- total_customers
- total_quantity
- net_revenue
- avg_ticket

---

### agg_sales_by_product
**Description:** Sales aggregated by product  
**Grain:** 1 row per product

Key metrics:
- total_orders
- total_customers
- total_quantity
- gross_revenue
- net_revenue
- total_discount_amount
- avg_line_revenue

---

### agg_sales_by_category
**Description:** Sales aggregated by category  
**Grain:** 1 row per category

Key metrics:
- total_orders
- total_products_sold
- total_quantity
- gross_revenue
- net_revenue
- total_discount_amount
- avg_line_revenue

---

### agg_customer_behavior
**Description:** Customer-level behavior metrics  
**Grain:** 1 row per customer

Key metrics:
- total_orders
- total_revenue
- avg_order_value
- avg_days_between_orders

---

### agg_customer_churn_risk
**Description:** Customer churn classification based on inactivity  
**Grain:** 1 row per customer

Key metrics:
- total_orders
- total_revenue
- avg_order_value
- total_quantity
- avg_days_between_orders
- days_since_last_order
- churn_risk_status

---

### agg_shipping_performance.sql
**Description:** Shipping performance metrics aggregated by shipper  
**Grain:** 1 row per shipper

Key metrics:
- total_orders
- avg_freight_amount
- avg_days_to_ship
- on_time_delivery_rate

---

## Business Rules and Metrics

- **Gross Revenue** = unit_price × quantity  
- **Net Revenue** = unit_price × quantity × (1 - discount)  
- **Discount Amount** = unit_price × quantity × discount  
- **Average Ticket** = total revenue / total orders  
- **Days to Ship** = shipped_date - order_date  

### Churn Definition

Customers are classified based on inactivity:

- **Active:** Customers who purchased within the last 30 days 
- **Attention:** Customers inactive for 31–60 days 
- **At Risk:** Customers inactive for 61–90 days 
- **Churned:** Customers inactive for more than 90 days

---

## Data Quality Notes

- IDs were standardized and cast to appropriate data types
- Text fields were trimmed and normalized
- Business keys were preserved where relevant
- Missing values were handled conservatively to avoid data loss
- Churn is inferred (not explicitly provided in source data)

---

## Notes

This data model was designed to support:
- executive dashboards
- product and customer analysis
- churn and retention insights

The structure follows best practices in analytics engineering, including modular transformations and clear separation of concerns across layers.
