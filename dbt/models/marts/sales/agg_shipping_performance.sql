select
    shipper_id,
    count(distinct order_id) as total_orders,
    avg(freight_amount) as avg_freight_amount,
    avg(days_to_ship) as avg_days_to_ship,
    avg(shipped_on_time_flag) as on_time_delivery_rate
from {{ ref('fct_orders') }}
group by shipper_id
order by total_orders desc