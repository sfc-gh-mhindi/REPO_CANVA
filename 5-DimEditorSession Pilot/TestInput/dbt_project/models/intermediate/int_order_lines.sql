-- ANTI-PATTERN: Duplicates order enrichment logic
SELECT
    o.order_id,
    o.order_date,
    o.order_total,
    o.customer_id,
    o.customer_full_name,
    o.product_id,
    o.product_name,
    o.product_category,
    o.product_brand,
    o.quantity_ordered,
    o.product_unit_price,
    o.quantity_ordered * o.product_unit_price as line_total,
    p.cost_price,
    (o.product_unit_price - p.cost_price) * o.quantity_ordered as line_margin,
    o.shipping_carrier,
    o.shipped_date,
    o.delivered_date,
    DATEDIFF('day', o.shipped_date, o.delivered_date) as delivery_days,
    -- Same calculation as elsewhere
    CASE
        WHEN o.order_total > 1000 THEN 'HIGH'
        WHEN o.order_total > 500 THEN 'MEDIUM'
        ELSE 'LOW'
    END as order_size
FROM {{ ref('stg_orders_v2') }} o
LEFT JOIN {{ ref('stg_products') }} p ON o.product_id = p.product_id
