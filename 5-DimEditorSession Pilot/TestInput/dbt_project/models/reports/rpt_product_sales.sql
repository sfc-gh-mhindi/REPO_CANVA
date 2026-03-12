-- ANTI-PATTERN: Another aggregation with same base logic
SELECT
    product_category as category,
    product_subcategory as subcategory,
    product_brand as brand,
    DATE_TRUNC('month', order_date) as month,
    COUNT(DISTINCT order_id) as order_count,
    SUM(quantity_ordered) as units_sold,
    SUM(order_total) as revenue,
    AVG(order_total) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_buyers
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status NOT IN ('CANCELLED')
GROUP BY 1, 2, 3, 4
