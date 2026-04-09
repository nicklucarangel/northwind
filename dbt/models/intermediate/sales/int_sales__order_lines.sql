with order_details as (

    select *
    from {{ ref('stg_erp__order_details') }}

),

orders as (

    select *
    from {{ ref('stg_erp__orders') }}

),

products as (

    select *
    from {{ ref('stg_erp__products') }}

),

final as (

    select
        od.order_id,
        o.customer_id,
        o.employee_id,
        o.shipper_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.ship_city,
        o.ship_region,
        o.ship_country,

        od.product_id,
        p.category_id,
        p.supplier_id,

        od.unit_price,
        od.quantity,
        od.discount,

        (od.unit_price * od.quantity) as gross_item_revenue,
        (od.unit_price * od.quantity * (1 - od.discount)) as net_item_revenue,
        (od.unit_price * od.quantity * od.discount) as discount_amount

    from order_details od
    inner join orders o
        on od.order_id = o.order_id
    left join products p
        on od.product_id = p.product_id

)

select *
from final