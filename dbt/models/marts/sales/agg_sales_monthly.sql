select
    date_trunc('month', order_date)::date as month_start_date,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as total_customers,
    sum(total_quantity) as total_quantity,
    sum(gross_order_revenue) as gross_revenue,
    sum(net_order_revenue) as net_revenue,
    sum(total_discount_amount) as total_discount_amount,
    avg(net_order_revenue) as avg_ticket,
    avg(freight_amount) as avg_freight_amount
from {{ ref('fct_orders') }}
group by 1
order by 1