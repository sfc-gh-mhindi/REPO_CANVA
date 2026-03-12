-- ANTI-PATTERN: Mart that joins multiple overlapping intermediates
SELECT
    c360.customer_id,
    c360.full_name,
    c360.email,
    c360.city,
    c360.state,
    c360.country,
    c360.customer_lifecycle_stage,
    c360.value_tier as lifecycle_tier,
    cs.segment as revenue_segment,
    cm.revenue_tier as metrics_tier,
    c360.total_orders,
    c360.lifetime_revenue,
    c360.avg_order_value,
    c360.first_order_date,
    c360.last_order_date,
    c360.days_since_last_order,
    c360.total_returns,
    c360.total_refunded,
    c360.total_tickets,
    c360.avg_satisfaction,
    c360.total_sessions
FROM {{ ref('int_customer_360') }} c360
LEFT JOIN {{ ref('int_customer_summary') }} cs ON c360.customer_id = cs.customer_id
LEFT JOIN {{ ref('int_customer_metrics') }} cm ON c360.customer_id = cm.customer_id
