-- ANTI-PATTERN: Shipping aggregates duplicating stg_shipping_events
SELECT
    carrier_code,
    carrier_name,
    service_type,
    DATE_TRUNC('month', event_timestamp) as month,
    COUNT(DISTINCT tracking_number) as shipments,
    COUNT(DISTINCT CASE WHEN event_type = 'DELIVERED' THEN tracking_number END) as delivered,
    AVG(DATEDIFF('day', 
        MIN(CASE WHEN event_type = 'LABEL_CREATED' THEN event_timestamp END),
        MAX(CASE WHEN event_type = 'DELIVERED' THEN event_timestamp END)
    )) as avg_delivery_days,
    SUM(shipping_cost) as total_shipping_cost
FROM DBT_REFACTOR_TEST.RAW.RAW_SHIPPING_EVENTS
GROUP BY 1, 2, 3, 4
