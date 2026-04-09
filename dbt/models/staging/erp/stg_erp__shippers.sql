select
    cast(shipper_id as integer) as shipper_id,
    company_name as shipper_name,
    phone as phone_raw,

    -- remove tudo que não é número
    regexp_replace(phone, '[^0-9]', '', 'g') as phone_clean

from {{ source('raw', 'shippers') }}