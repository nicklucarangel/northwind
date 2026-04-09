select
    cast(product_id as integer) as product_id,
    product_name,
    cast(supplier_id as integer) as supplier_id,
    cast(category_id as integer) as category_id,
    quantity_per_unit,
    cast(unit_price as numeric(12,2)) as unit_price,
    cast(units_in_stock as integer) as units_in_stock,
    cast(units_on_order as integer) as units_on_order,
    cast(reorder_level as integer) as reorder_level,
    cast(discontinued as integer) as is_discontinued
from {{ source('raw', 'products') }}