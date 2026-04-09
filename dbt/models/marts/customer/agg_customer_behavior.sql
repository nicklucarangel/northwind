with orders as (

    select *
    from {{ ref('fct_orders') }}

),

customer_order_dates as (

    select
        customer_id,
        order_id,
        order_date,
        lag(order_date) over (
            partition by customer_id
            order by order_date
        ) as previous_order_date
    from orders

),

customer_purchase_gaps as (

    select
        customer_id,
        order_id,
        order_date,
        previous_order_date,
        (order_date - previous_order_date) as days_since_previous_order
    from customer_order_dates

),

final as (

    select
        o.customer_id,
        count(distinct o.order_id) as total_orders,
        sum(o.net_order_revenue) as total_revenue,
        avg(o.net_order_revenue) as avg_order_value,
        sum(o.total_quantity) as total_quantity,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date,
        avg(g.days_since_previous_order) as avg_days_between_orders
    from orders o
    left join customer_purchase_gaps g
        on o.customer_id = g.customer_id
        and o.order_id = g.order_id
    group by o.customer_id

)

select *
from final