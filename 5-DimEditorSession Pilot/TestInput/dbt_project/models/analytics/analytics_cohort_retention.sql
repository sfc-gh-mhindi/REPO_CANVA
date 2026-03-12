-- ANTI-PATTERN: Cohort analysis with inline logic
WITH first_orders AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) as cohort_month
    FROM {{ ref('fct_orders') }}
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_date) as activity_month,
        COUNT(DISTINCT o.order_id) as orders,
        SUM(o.order_amount) as revenue
    FROM {{ ref('fct_orders') }} o
    GROUP BY 1, 2
)
SELECT
    f.cohort_month,
    m.activity_month,
    DATEDIFF('month', f.cohort_month, m.activity_month) as months_since_first,
    COUNT(DISTINCT m.customer_id) as active_customers,
    SUM(m.orders) as total_orders,
    SUM(m.revenue) as total_revenue,
    AVG(m.revenue) as avg_revenue_per_customer
FROM first_orders f
JOIN monthly_activity m ON f.customer_id = m.customer_id
GROUP BY 1, 2, 3
