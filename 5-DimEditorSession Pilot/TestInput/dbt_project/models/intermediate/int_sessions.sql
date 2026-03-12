-- ANTI-PATTERN: Manual sessionization that should use staging
SELECT
    session_id,
    user_id as customer_id,
    user_email,
    MIN(event_timestamp) as session_start,
    MAX(event_timestamp) as session_end,
    DATEDIFF('second', MIN(event_timestamp), MAX(event_timestamp)) as session_duration_seconds,
    COUNT(DISTINCT event_id) as event_count,
    COUNT(DISTINCT CASE WHEN event_type = 'PAGE_VIEW' THEN event_id END) as page_views,
    COUNT(DISTINCT CASE WHEN event_type = 'ADD_TO_CART' THEN event_id END) as cart_adds,
    COUNT(DISTINCT CASE WHEN event_type = 'CHECKOUT_START' THEN event_id END) as checkout_starts,
    MAX(device_type) as device_type,
    MAX(device_browser) as browser,
    MAX(geo_country) as country,
    MAX(utm_source) as utm_source,
    MAX(utm_medium) as utm_medium,
    MAX(utm_campaign) as utm_campaign,
    ARRAY_AGG(DISTINCT page_path) as pages_visited
FROM {{ ref('stg_clickstream') }}
GROUP BY session_id, user_id, user_email
