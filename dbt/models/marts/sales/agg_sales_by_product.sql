with sales as (

    select *
    from {{ ref('fct_order_lines') }}

),

products as (

    select *
    from {{ ref('dim_products') }}

),

final as (

    select
        s.product_id,
        p.product_name,
        p.category_name,
        p.supplier_name,
        count(distinct s.order_id) as total_orders,
        count(distinct s.customer_id) as total_customers,
        sum(s.quantity) as total_quantity,
        sum(s.gross_item_revenue) as gross_revenue,
        sum(s.net_item_revenue) as net_revenue,
        sum(s.discount_amount) as total_discount_amount,
        avg(s.net_item_revenue) as avg_line_revenue
    from sales s
    left join products p
        on s.product_id = p.product_id
    group by
        s.product_id,
        p.product_name,
        p.category_name,
        p.supplier_name

)

select *
from final
order by net_revenue desc