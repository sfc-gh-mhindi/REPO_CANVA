-- ANTI-PATTERN: Report directly queries raw with complex logic
SELECT
    DATE_TRUNC('day', order_date) as sale_date,
    DATE_TRUNC('week', order_date) as sale_week,
    DATE_TRUNC('month', order_date) as sale_month,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(order_total) as gross_revenue,
    SUM(order_discount) as total_discounts,
    SUM(order_tax) as total_tax,
    SUM(order_shipping_cost) as total_shipping,
    SUM(order_total - order_discount + order_tax + order_shipping_cost) as net_revenue,
    AVG(order_total) as avg_order_value,
    SUM(quantity_ordered) as total_units,
    -- Repeated calculation
    CASE
        WHEN SUM(order_total) > 100000 THEN 'HIGH'
        WHEN SUM(order_total) > 50000 THEN 'MEDIUM'
        ELSE 'LOW'
    END as daily_volume_tier
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
WHERE order_status NOT IN ('CANCELLED', 'FAILED')
GROUP BY 1, 2, 3
