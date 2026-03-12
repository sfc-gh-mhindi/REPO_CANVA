-- ANTI-PATTERN: Returns report with duplicate logic
SELECT
    DATE_TRUNC('month', return_date) as return_month,
    return_reason,
    return_status,
    COUNT(DISTINCT return_id) as return_count,
    SUM(quantity_returned) as units_returned,
    SUM(refund_amount) as total_refunded,
    AVG(refund_amount) as avg_refund,
    COUNT(DISTINCT customer_id) as customers_with_returns,
    AVG(days_to_return) as avg_days_to_return,
    SUM(CASE WHEN restockable = TRUE THEN 1 ELSE 0 END) as restockable_returns
FROM {{ ref('fct_returns') }}
GROUP BY 1, 2, 3
