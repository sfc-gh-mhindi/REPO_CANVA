-- ANTI-PATTERN: Analytics model duplicating mart logic
SELECT
    d.date_day as analysis_date,
    d.day_name,
    d.month_name,
    d.quarter,
    d.year,
    d.is_weekend,
    COUNT(DISTINCT o.order_id) as orders,
    SUM(o.order_amount) as revenue,
    AVG(o.order_amount) as aov,
    COUNT(DISTINCT o.customer_id) as customers,
    SUM(o.line_margin) as gross_profit,
    SUM(o.line_margin) / NULLIF(SUM(o.order_amount), 0) as gross_margin_pct
FROM {{ ref('dim_date') }} d
LEFT JOIN {{ ref('fct_orders') }} o ON DATE(o.order_date) = d.date_day
GROUP BY 1, 2, 3, 4, 5, 6
