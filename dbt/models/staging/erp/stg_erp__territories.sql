select
    cast(territory_id as integer) as territory_id,
    territory_description,
    cast(region_id as integer) as region_id
from {{ source('raw', 'territories') }}
