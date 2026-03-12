-- ANTI-PATTERN: Another duplicate aggregation
SELECT
    DATE_TRUNC('week', order_date) as week,
    sales_rep_region as region,
    COUNT(DISTINCT order_id) as order_count,
    SUM(order_total) as total_sales,
    COUNT(DISTINCT customer_id) as customer_count,
    AVG(order_total) as avg_order_value
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status = 'COMPLETED'
GROUP BY 1, 2
