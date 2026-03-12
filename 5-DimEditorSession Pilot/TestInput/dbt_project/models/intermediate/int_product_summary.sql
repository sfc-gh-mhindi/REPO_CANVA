-- ANTI-PATTERN: Another product summary that overlaps
SELECT
    p.id as product_id,
    p.product_sku as sku,
    p.name as product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.price as retail_price,
    p.cost as cost_price,
    p.margin,
    p.margin_pct,
    p.stock as current_stock,
    COUNT(DISTINCT o.ord_id) as order_count,
    SUM(o.quantity_ordered) as total_units_sold,
    SUM(o.total_amt) as total_revenue,
    AVG(o.total_amt) as avg_order_value
FROM {{ ref('stg_products_active') }} p
LEFT JOIN {{ ref('stg_orders') }} o ON p.product_id = o.product_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
