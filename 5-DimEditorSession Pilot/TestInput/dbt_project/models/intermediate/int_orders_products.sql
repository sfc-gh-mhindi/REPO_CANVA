-- ANTI-PATTERN: Yet another order enrichment
WITH base_orders AS (
    SELECT
        order_id,
        order_date,
        customer_id,
        order_total,
        order_tax,
        order_shipping_cost,
        order_discount,
        product_id,
        quantity_ordered
    FROM {{ ref('stg_orders_v2') }}
),
product_info AS (
    SELECT
        product_id,
        product_name,
        category_l1_name,
        category_l2_name,
        brand_name,
        retail_price,
        cost_price
    FROM {{ ref('stg_products') }}
)
SELECT
    b.*,
    p.product_name,
    p.category_l1_name as category,
    p.category_l2_name as subcategory,
    p.brand_name as brand,
    p.retail_price,
    p.cost_price,
    p.retail_price - p.cost_price as unit_margin,
    b.order_total + b.order_tax + b.order_shipping_cost - b.order_discount as grand_total,
    -- Repeated tier calculation
    CASE
        WHEN b.order_total > 1000 THEN 'LARGE'
        WHEN b.order_total > 500 THEN 'MEDIUM'
        WHEN b.order_total > 100 THEN 'SMALL'
        ELSE 'MINI'
    END as order_bucket
FROM base_orders b
LEFT JOIN product_info p ON b.product_id = p.product_id
