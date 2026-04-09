select
    customer_id,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax,
    regexp_replace(phone, '[^0-9]', '', 'g') as phone_clean,
    regexp_replace(fax, '[^0-9]', '', 'g') as fax_clean
from {{ source('raw', 'customers') }}