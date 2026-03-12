-- ANTI-PATTERN: Duplicates int_customer_360 logic
-- ANTI-PATTERN: Different column names for same metrics
WITH orders_agg AS (
    SELECT
        customer_id,
        COUNT(*) as order_count,
        SUM(order_total) as revenue,
        AVG(order_total) as aov,
        MIN(order_date) as first_purchase,
        MAX(order_date) as last_purchase
    FROM {{ ref('stg_orders') }}
    GROUP BY customer_id
),
returns_agg AS (
    SELECT
        customer_id,
        COUNT(*) as return_count,
        SUM(refund_amount) as refund_total
    FROM {{ ref('stg_returns') }}
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.state,
    c.country,
    COALESCE(o.order_count, 0) as orders,
    COALESCE(o.revenue, 0) as total_spend,
    COALESCE(o.aov, 0) as average_order,
    o.first_purchase,
    o.last_purchase,
    COALESCE(r.return_count, 0) as returns,
    COALESCE(r.refund_total, 0) as refunds,
    -- Same calculation, slightly different thresholds
    CASE
        WHEN COALESCE(o.revenue, 0) >= 10000 THEN 'VIP'
        WHEN COALESCE(o.revenue, 0) >= 5000 THEN 'PREMIUM'
        WHEN COALESCE(o.revenue, 0) >= 1000 THEN 'STANDARD'
        ELSE 'ENTRY'
    END as segment
FROM {{ ref('stg_customers_v1') }} c
LEFT JOIN orders_agg o ON c.customer_id = o.customer_id
LEFT JOIN returns_agg r ON c.customer_id = r.customer_id
