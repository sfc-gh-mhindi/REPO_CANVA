-- ANTI-PATTERN: Web analytics duplicating session logic
SELECT
    DATE(s.session_start) as session_date,
    s.device_type,
    s.utm_source,
    s.utm_medium,
    s.country,
    COUNT(DISTINCT s.session_id) as sessions,
    COUNT(DISTINCT s.customer_id) as unique_users,
    SUM(s.page_views) as total_page_views,
    AVG(s.page_views) as avg_pages_per_session,
    AVG(s.session_duration_seconds) as avg_session_duration,
    SUM(s.cart_adds) as total_cart_adds,
    SUM(s.checkout_starts) as total_checkouts,
    SUM(s.cart_adds) / NULLIF(COUNT(DISTINCT s.session_id), 0) as cart_add_rate,
    SUM(s.checkout_starts) / NULLIF(SUM(s.cart_adds), 0) as checkout_rate
FROM {{ ref('fct_sessions') }} s
GROUP BY 1, 2, 3, 4, 5
