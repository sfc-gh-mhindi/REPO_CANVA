-- ANTI-PATTERN: Customer report duplicates intermediate logic
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.customer_lifecycle_stage,
    c.value_tier,
    c.total_orders,
    c.lifetime_revenue,
    c.avg_order_value,
    c.first_order_date,
    c.last_order_date,
    c.days_since_last_order,
    c.total_returns,
    c.total_refunded,
    c.total_tickets,
    -- Same RFM calculation done elsewhere
    CASE
        WHEN c.days_since_last_order <= 30 THEN 5
        WHEN c.days_since_last_order <= 60 THEN 4
        WHEN c.days_since_last_order <= 90 THEN 3
        WHEN c.days_since_last_order <= 180 THEN 2
        ELSE 1
    END as recency_score,
    CASE
        WHEN c.total_orders >= 10 THEN 5
        WHEN c.total_orders >= 5 THEN 4
        WHEN c.total_orders >= 3 THEN 3
        WHEN c.total_orders >= 1 THEN 2
        ELSE 1
    END as frequency_score,
    CASE
        WHEN c.lifetime_revenue >= 5000 THEN 5
        WHEN c.lifetime_revenue >= 2500 THEN 4
        WHEN c.lifetime_revenue >= 1000 THEN 3
        WHEN c.lifetime_revenue >= 500 THEN 2
        ELSE 1
    END as monetary_score
FROM {{ ref('int_customer_360') }} c
