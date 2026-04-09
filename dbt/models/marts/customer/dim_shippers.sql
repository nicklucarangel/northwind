select
    shipper_id,
    shipper_name,
    phone_raw,
    phone_clean
from {{ ref('stg_erp__shippers') }}