-- ANTI-PATTERN: Fact table that re-derives dimensions
SELECT
    o.order_id,
    o.order_date,
    DATE_TRUNC('month', o.order_date) as order_month,
    DATE_TRUNC('quarter', o.order_date) as order_quarter,
    YEAR(o.order_date) as order_year,
    o.customer_id,
    -- Re-embedding customer info instead of FK
    o.customer_full_name,
    o.product_id,
    -- Re-embedding product info instead of FK
    o.product_name,
    o.product_category,
    o.product_brand,
    o.quantity_ordered,
    o.order_total as order_amount,
    ol.line_total,
    ol.line_margin,
    o.order_shipping_cost,
    o.order_tax,
    o.order_discount,
    o.order_total + o.order_tax + o.order_shipping_cost - o.order_discount as grand_total,
    o.shipped_date,
    o.delivered_date,
    ol.delivery_days,
    o.shipping_carrier,
    -- Repeated tier calculation
    CASE
        WHEN o.order_total > 1000 THEN 'LARGE'
        WHEN o.order_total > 500 THEN 'MEDIUM'
        WHEN o.order_total > 100 THEN 'SMALL'
        ELSE 'MICRO'
    END as order_tier
FROM {{ ref('stg_orders_v2') }} o
LEFT JOIN {{ ref('int_order_lines') }} ol ON o.order_id = ol.order_id
