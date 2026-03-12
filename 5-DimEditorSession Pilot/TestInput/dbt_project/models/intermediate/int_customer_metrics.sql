-- ANTI-PATTERN: Third customer aggregation with same logic
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.loyalty_tier,
    c.subscription_status,
    COUNT(DISTINCT o.ord_id) as num_orders,
    SUM(o.total_amt) as total_revenue,
    AVG(o.total_amt) as avg_order,
    MAX(o.ord_dt) as most_recent_order,
    -- Same tier logic, different naming
    CASE
        WHEN SUM(o.total_amt) > 10000 THEN 'TIER_1'
        WHEN SUM(o.total_amt) > 5000 THEN 'TIER_2'
        WHEN SUM(o.total_amt) > 1000 THEN 'TIER_3'
        ELSE 'TIER_4'
    END as revenue_tier
FROM {{ ref('stg_customers_v2') }} c
LEFT JOIN {{ ref('stg_orders') }} o ON c.customer_id = o.cust_id
GROUP BY 1, 2, 3, 4, 5
