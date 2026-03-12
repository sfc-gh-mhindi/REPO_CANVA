-- ANTI-PATTERN: Massive CTE with repeated logic
-- ANTI-PATTERN: Re-reading raw tables instead of using staging
-- ANTI-PATTERN: Complex business logic embedded in SQL
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(order_total) as total_revenue,
        AVG(order_total) as avg_order_value,
        MIN(order_date) as first_order_date,
        MAX(order_date) as last_order_date,
        DATEDIFF('day', MAX(order_date), CURRENT_DATE()) as days_since_last_order
    FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
    WHERE order_status NOT IN ('CANCELLED', 'FAILED')
    GROUP BY customer_id
),
customer_returns AS (
    SELECT
        customer_id,
        COUNT(DISTINCT return_id) as total_returns,
        SUM(refund_amount) as total_refunded
    FROM DBT_REFACTOR_TEST.RAW.RAW_RETURNS
    WHERE return_status = 'REFUNDED'
    GROUP BY customer_id
),
customer_tickets AS (
    SELECT
        customer_id,
        COUNT(DISTINCT ticket_id) as total_tickets,
        SUM(CASE WHEN ticket_priority = 'URGENT' THEN 1 ELSE 0 END) as urgent_tickets,
        AVG(satisfaction_rating) as avg_satisfaction
    FROM DBT_REFACTOR_TEST.RAW.RAW_SUPPORT_TICKETS
    GROUP BY customer_id
),
customer_sessions AS (
    SELECT
        user_id as customer_id,
        COUNT(DISTINCT session_id) as total_sessions,
        COUNT(DISTINCT event_id) as total_events,
        SUM(CASE WHEN event_type = 'ADD_TO_CART' THEN 1 ELSE 0 END) as cart_adds
    FROM DBT_REFACTOR_TEST.RAW.RAW_CLICKSTREAM
    WHERE user_id IS NOT NULL
    GROUP BY user_id
)
SELECT
    c.cust_id as customer_id,
    c.first_name,
    c.last_name,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.phone,
    c.registration_date,
    c.account_status,
    c.city,
    c.state,
    c.country,
    c.customer_score,
    c.acquisition_source,
    -- Order metrics
    COALESCE(o.total_orders, 0) as total_orders,
    COALESCE(o.total_revenue, 0) as lifetime_revenue,
    COALESCE(o.avg_order_value, 0) as avg_order_value,
    o.first_order_date,
    o.last_order_date,
    o.days_since_last_order,
    -- Return metrics
    COALESCE(r.total_returns, 0) as total_returns,
    COALESCE(r.total_refunded, 0) as total_refunded,
    -- Support metrics
    COALESCE(t.total_tickets, 0) as total_tickets,
    COALESCE(t.urgent_tickets, 0) as urgent_tickets,
    t.avg_satisfaction,
    -- Session metrics
    COALESCE(s.total_sessions, 0) as total_sessions,
    COALESCE(s.total_events, 0) as total_events,
    -- ANTI-PATTERN: Complex derived calculations
    CASE
        WHEN COALESCE(o.total_orders, 0) = 0 THEN 'NO_PURCHASE'
        WHEN o.days_since_last_order <= 30 AND o.total_orders >= 5 THEN 'ACTIVE_LOYAL'
        WHEN o.days_since_last_order <= 30 THEN 'ACTIVE'
        WHEN o.days_since_last_order <= 90 THEN 'AT_RISK'
        WHEN o.days_since_last_order <= 180 THEN 'LAPSED'
        ELSE 'CHURNED'
    END as customer_lifecycle_stage,
    -- ANTI-PATTERN: Same tier calculation again
    CASE
        WHEN COALESCE(o.total_revenue, 0) > 10000 THEN 'PLATINUM'
        WHEN COALESCE(o.total_revenue, 0) > 5000 THEN 'GOLD'
        WHEN COALESCE(o.total_revenue, 0) > 1000 THEN 'SILVER'
        ELSE 'BRONZE'
    END as value_tier
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1 c
LEFT JOIN customer_orders o ON c.cust_id = o.customer_id
LEFT JOIN customer_returns r ON c.cust_id = r.customer_id
LEFT JOIN customer_tickets t ON c.cust_id = t.customer_id
LEFT JOIN customer_sessions s ON c.cust_id = s.customer_id
