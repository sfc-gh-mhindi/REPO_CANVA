-- ANTI-PATTERN: Third customer staging with union logic that should be in intermediate
SELECT
    cust_id as customer_id,
    first_name,
    last_name,
    email,
    phone,
    'V1' as source_system,
    registration_date as created_date
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1

UNION ALL

SELECT
    customer_key as customer_id,
    name_first as first_name,
    name_last as last_name,
    email_primary as email,
    phone_mobile as phone,
    'V2' as source_system,
    sys_created_ts::DATE as created_date
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V2
