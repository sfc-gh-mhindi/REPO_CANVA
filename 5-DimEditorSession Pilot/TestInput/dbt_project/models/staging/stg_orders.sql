-- ANTI-PATTERN: Hardcoded database/schema, no source reference
-- ANTI-PATTERN: Inconsistent column naming
-- ANTI-PATTERN: Complex transformations that should be broken down
SELECT
    order_id as ord_id,
    order_date as ord_dt,
    order_status as status,
    order_total as total_amt,
    order_tax as tax,
    order_shipping_cost as ship_cost,
    order_discount as discount,
    customer_id as cust_id,
    customer_first_name as first_nm,
    customer_last_name as last_nm,
    customer_email as email,
    -- ANTI-PATTERN: Inline calculation that's repeated elsewhere
    CASE
        WHEN order_total > 1000 THEN 'HIGH_VALUE'
        WHEN order_total > 500 THEN 'MEDIUM_VALUE'
        WHEN order_total > 100 THEN 'LOW_VALUE'
        ELSE 'MICRO'
    END as order_value_tier,
    -- ANTI-PATTERN: Hardcoded date logic
    CASE
        WHEN order_date >= '2024-01-01' THEN 'CURRENT_YEAR'
        WHEN order_date >= '2023-01-01' THEN 'PRIOR_YEAR'
        ELSE 'HISTORICAL'
    END as year_category,
    product_id,
    product_name,
    product_category,
    quantity_ordered,
    created_at,
    updated_at
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status != 'CANCELLED'
