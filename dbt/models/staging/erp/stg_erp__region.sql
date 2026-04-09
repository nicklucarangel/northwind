select
    cast(region_id as integer) as region_id,
    region_description
from {{ source('raw', 'region') }}