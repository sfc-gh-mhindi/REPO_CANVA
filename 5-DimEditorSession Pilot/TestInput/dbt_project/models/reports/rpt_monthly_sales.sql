-- ANTI-PATTERN: Duplicate of daily sales at different grain
SELECT
    DATE_TRUNC('month', order_date) as sale_month,
    YEAR(order_date) as sale_year,
    QUARTER(order_date) as sale_quarter,
    COUNT(DISTINCT order_id) as orders,
    COUNT(DISTINCT customer_id) as customers,
    SUM(order_total) as revenue,
    SUM(order_discount) as discounts,
    SUM(order_total) - SUM(order_discount) as net_revenue,
    AVG(order_total) as aov,
    SUM(quantity_ordered) as units
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status = 'COMPLETED'
GROUP BY 1, 2, 3
