select
    cast(state_id as integer) as state_id,
    trim(state_name) as state_name,
    upper(trim(state_abbr)) as state_abbr,
    trim(state_region) as state_region
from {{ source('raw', 'us_states') }}
