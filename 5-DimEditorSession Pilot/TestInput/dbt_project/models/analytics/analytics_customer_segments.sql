-- ANTI-PATTERN: Customer segmentation redoing segment logic
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.customer_lifecycle_stage,
    c.value_tier,
    c.total_orders,
    c.lifetime_revenue,
    c.avg_order_value,
    c.days_since_last_order,
    -- Re-calculating segments
    CASE
        WHEN c.lifetime_revenue >= 10000 AND c.total_orders >= 10 AND c.days_since_last_order <= 30 THEN 'CHAMPION'
        WHEN c.lifetime_revenue >= 5000 AND c.total_orders >= 5 THEN 'LOYAL'
        WHEN c.days_since_last_order <= 30 AND c.total_orders <= 2 THEN 'NEW_ACTIVE'
        WHEN c.days_since_last_order > 90 AND c.lifetime_revenue >= 5000 THEN 'AT_RISK_HIGH_VALUE'
        WHEN c.days_since_last_order > 90 THEN 'DORMANT'
        ELSE 'DEVELOPING'
    END as customer_segment,
    -- Predicted next action
    CASE
        WHEN c.days_since_last_order > 90 THEN 'WINBACK_CAMPAIGN'
        WHEN c.total_orders = 1 AND c.days_since_last_order <= 30 THEN 'SECOND_PURCHASE_PUSH'
        WHEN c.avg_order_value < 100 THEN 'UPSELL_OPPORTUNITY'
        ELSE 'MAINTAIN_ENGAGEMENT'
    END as recommended_action
FROM {{ ref('dim_customers') }} c
