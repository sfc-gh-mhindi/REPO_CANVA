-- ANTI-PATTERN: Store dimension built inline
SELECT DISTINCT
    store_id,
    store_name,
    store_city,
    store_state,
    store_region,
    store_district
FROM {{ ref('stg_employee_sales') }}
WHERE store_id IS NOT NULL
