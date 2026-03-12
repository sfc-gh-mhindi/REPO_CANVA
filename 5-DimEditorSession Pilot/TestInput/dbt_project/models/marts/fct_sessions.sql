-- ANTI-PATTERN: Sessions fact with duplicate dimension info
SELECT
    s.session_id,
    s.customer_id,
    s.user_email,
    s.session_start,
    s.session_end,
    DATE(s.session_start) as session_date,
    s.session_duration_seconds,
    s.event_count,
    s.page_views,
    s.cart_adds,
    s.checkout_starts,
    s.device_type,
    s.browser,
    s.country,
    s.utm_source,
    s.utm_medium,
    s.utm_campaign,
    c.full_name as customer_name,
    c.customer_lifecycle_stage,
    c.value_tier as customer_tier,
    -- Session quality score
    CASE
        WHEN s.checkout_starts > 0 THEN 'HIGH_INTENT'
        WHEN s.cart_adds > 0 THEN 'MEDIUM_INTENT'
        WHEN s.page_views > 5 THEN 'BROWSING'
        ELSE 'BOUNCED'
    END as session_quality
FROM {{ ref('int_sessions') }} s
LEFT JOIN {{ ref('int_customer_360') }} c ON s.customer_id = c.customer_id
