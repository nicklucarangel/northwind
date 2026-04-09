select
    cast(category_id as integer) as category_id,
    category_name,
    description
from {{ source('raw', 'categories') }}