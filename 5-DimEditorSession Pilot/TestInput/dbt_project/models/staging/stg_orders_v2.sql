-- ANTI-PATTERN: Duplicate of stg_orders with slightly different logic
-- ANTI-PATTERN: Different column names for same concepts
SELECT
    order_id,
    order_date,
    order_status,
    order_total,
    order_tax,
    order_shipping_cost,
    order_discount,
    -- ANTI-PATTERN: Same calculation as stg_orders but different implementation
    CASE
        WHEN order_total >= 1000 THEN 'HIGH'
        WHEN order_total >= 500 THEN 'MED'
        WHEN order_total >= 100 THEN 'LOW'
        ELSE 'MICRO'
    END as value_segment,
    customer_id,
    customer_first_name || ' ' || customer_last_name as customer_full_name,
    customer_email,
    product_id,
    product_name,
    product_category,
    product_subcategory,
    product_brand,
    product_unit_price,
    quantity_ordered,
    shipping_carrier,
    shipping_method,
    shipped_date,
    delivered_date,
    created_at
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
