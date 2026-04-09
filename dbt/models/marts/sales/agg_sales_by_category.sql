with sales as (

    select *
    from {{ ref('fct_order_lines') }}

),

categories as (

    select *
    from {{ ref('stg_erp__categories') }}

),

final as (

    select
        s.category_id,
        c.category_name,
        count(distinct s.order_id) as total_orders,
        count(distinct s.product_id) as total_products_sold,
        sum(s.quantity) as total_quantity,
        sum(s.gross_item_revenue) as gross_revenue,
        sum(s.net_item_revenue) as net_revenue,
        sum(s.discount_amount) as total_discount_amount,
        avg(s.net_item_revenue) as avg_line_revenue
    from sales s
    left join categories c
        on s.category_id = c.category_id
    group by
        s.category_id,
        c.category_name

)

select *
from final
order by net_revenue desc