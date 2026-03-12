-- ANTI-PATTERN: Support report with redundant customer join
SELECT
    DATE_TRUNC('month', t.created_at) as ticket_month,
    t.ticket_type,
    t.ticket_priority,
    t.channel,
    COUNT(DISTINCT t.ticket_id) as ticket_count,
    COUNT(DISTINCT t.customer_id) as unique_customers,
    AVG(t.satisfaction_rating) as avg_satisfaction,
    SUM(CASE WHEN t.sla_first_response_breached = TRUE THEN 1 ELSE 0 END) as sla_breaches,
    AVG(DATEDIFF('hour', t.created_at, t.first_response_at)) as avg_first_response_hours,
    AVG(DATEDIFF('hour', t.created_at, t.resolved_at)) as avg_resolution_hours
FROM {{ ref('stg_support_tickets') }} t
GROUP BY 1, 2, 3, 4
