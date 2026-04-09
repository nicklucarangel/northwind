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
    --phone_clean,
    fax,
    --fax_clean
from {{ ref('stg_erp__customers') }}