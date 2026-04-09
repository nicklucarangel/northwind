select
    cast(supplier_id as integer) as supplier_id,
    company_name as supplier_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone as phone_raw,
    regexp_replace(phone, '[^0-9]', '', 'g') as phone_clean,
    fax as fax_raw,
    regexp_replace(fax, '[^0-9]', '', 'g') as fax_clean,
    homepage
from {{ source('raw', 'suppliers') }}