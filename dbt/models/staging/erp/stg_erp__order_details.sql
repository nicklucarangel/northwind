select
    cast(order_id as integer) as order_id,
    cast(product_id as integer) as product_id,
    cast(unit_price as numeric(12,2)) as unit_price,
    cast(quantity as integer) as quantity,
    cast(discount as numeric(12,4)) as discount
from {{ source('raw', 'order_details') }}