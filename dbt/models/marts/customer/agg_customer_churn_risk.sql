with customer_behavior as (

    select *
    from {{ ref('agg_customer_behavior') }}

),

reference_date as (

    select max(order_date) as max_order_date
    from {{ ref('fct_orders') }}

),

final as (

    select
        cb.customer_id,
        cb.total_orders,
        cb.total_revenue,
        cb.avg_order_value,
        cb.total_quantity,
        cb.first_order_date,
        cb.last_order_date,
        cb.avg_days_between_orders,

        (r.max_order_date - cb.last_order_date) as days_since_last_order,

        case
            when (r.max_order_date - cb.last_order_date) <= 30 then 'Active'
            when (r.max_order_date - cb.last_order_date) <= 60 then 'Attention'
            when (r.max_order_date - cb.last_order_date) <= 90 then 'At Risk'
            else 'Churned'
        end as churn_risk_status

    from customer_behavior cb
    cross join reference_date r

)

select *
from final