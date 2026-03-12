-- ANTI-PATTERN: Aggregate model re-reading raw data
SELECT
    DATE_TRUNC('month', order_date) as month,
    product_category as category,
    COUNT(DISTINCT order_id) as orders,
    COUNT(DISTINCT customer_id) as customers,
    SUM(order_total) as revenue,
    SUM(quantity_ordered) as units,
    AVG(order_total) as aov
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status NOT IN ('CANCELLED', 'FAILED')
GROUP BY 1, 2
