select
    employee_id,
    employee_full_name,
    title,
    title_of_courtesy,
    birth_date,
    hire_date,
    address,
    city,
    region,
    postal_code,
    country,
    home_phone_raw,
    home_phone_clean,
    extension,
    reports_to_employee_id
from {{ ref('stg_erp__employees') }}