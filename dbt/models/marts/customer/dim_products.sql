with products as (

    select *
    from {{ ref('stg_erp__products') }}

),

categories as (

    select *
    from {{ ref('stg_erp__categories') }}

),

suppliers as (

    select *
    from {{ ref('stg_erp__suppliers') }}

),

final as (

    select
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        p.supplier_id,
        s.supplier_name,
        p.quantity_per_unit,
        p.unit_price,
        p.units_in_stock,
        p.units_on_order,
        p.reorder_level,
        p.is_discontinued
    from products p
    left join categories c
        on p.category_id = c.category_id
    left join suppliers s
        on p.supplier_id = s.supplier_id

)

select *
from final