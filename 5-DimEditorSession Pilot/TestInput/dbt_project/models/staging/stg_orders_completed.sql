-- ANTI-PATTERN: Yet another orders staging with different filters
-- ANTI-PATTERN: Repeated hardcoded logic
SELECT
    order_id as id,
    order_date as date,
    order_status,
    order_total as amount,
    order_tax + order_shipping_cost as fees,
    order_discount,
    order_total - order_discount + order_tax + order_shipping_cost as grand_total,
    customer_id,
    UPPER(customer_first_name) as customer_first_name,
    UPPER(customer_last_name) as customer_last_name,
    LOWER(customer_email) as customer_email,
    customer_tier,
    customer_lifetime_value,
    billing_city,
    billing_state,
    billing_country,
    shipping_city,
    shipping_state,
    shipping_country,
    payment_method,
    payment_status,
    sales_rep_id,
    sales_rep_name,
    sales_rep_region,
    -- ANTI-PATTERN: Same tier logic, different thresholds
    CASE
        WHEN order_total > 2000 THEN 'PREMIUM'
        WHEN order_total > 1000 THEN 'STANDARD'
        ELSE 'BASIC'
    END as service_tier
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status IN ('COMPLETED', 'SHIPPED', 'DELIVERED')
