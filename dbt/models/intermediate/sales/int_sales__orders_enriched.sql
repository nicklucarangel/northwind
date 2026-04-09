with order_lines as (

    select *
    from {{ ref('int_sales__order_lines') }}

),

orders as (

    select *
    from {{ ref('stg_erp__orders') }}

),

final as (

    select
        o.order_id,
        o.customer_id,
        o.employee_id,
        o.shipper_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.freight_amount,
        o.ship_city,
        o.ship_region,
        o.ship_country,

        count(distinct ol.product_id) as total_skus,
        sum(ol.quantity) as total_quantity,
        count(*) as total_order_lines,

        sum(ol.gross_item_revenue) as gross_order_revenue,
        sum(ol.net_item_revenue) as net_order_revenue,
        sum(ol.discount_amount) as total_discount_amount,

        case
            when sum(ol.gross_item_revenue) = 0 then null
            else sum(ol.discount_amount) / sum(ol.gross_item_revenue)
        end as avg_discount_rate,

        (o.shipped_date - o.order_date) as days_to_ship,

        case
            when o.shipped_date <= o.required_date then 1
            else 0
        end as shipped_on_time_flag

    from orders o
    left join order_lines ol
        on o.order_id = ol.order_id
    group by
        o.order_id,
        o.customer_id,
        o.employee_id,
        o.shipper_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.freight_amount,
        o.ship_city,
        o.ship_region,
        o.ship_country

)

select *
from final