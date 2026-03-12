-- ANTI-PATTERN: Calculates product metrics that duplicate stg_products
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category_l1_name as category,
    p.category_l2_name as subcategory,
    p.brand_name as brand,
    p.supplier_name,
    p.retail_price,
    p.cost_price,
    p.retail_price - p.cost_price as margin,
    (p.retail_price - p.cost_price) / NULLIF(p.retail_price, 0) as margin_pct,
    p.current_stock_qty as stock,
    p.reorder_point,
    p.is_active,
    p.is_featured,
    p.is_clearance,
    -- Inventory turnover (but duplicates logic elsewhere)
    COALESCE(i.total_sold, 0) as units_sold_all_time,
    COALESCE(i.total_received, 0) as units_received_all_time,
    -- Order metrics
    COALESCE(o.times_ordered, 0) as order_count,
    COALESCE(o.total_revenue, 0) as total_revenue,
    COALESCE(o.avg_order_qty, 0) as avg_order_qty
FROM {{ ref('stg_products') }} p
LEFT JOIN (
    SELECT
        product_id,
        SUM(CASE WHEN movement_type = 'SALE' THEN ABS(quantity_change) ELSE 0 END) as total_sold,
        SUM(CASE WHEN movement_type = 'RECEIPT' THEN quantity_change ELSE 0 END) as total_received
    FROM {{ ref('stg_inventory') }}
    GROUP BY product_id
) i ON p.product_id = i.product_id
LEFT JOIN (
    SELECT
        product_id,
        COUNT(*) as times_ordered,
        SUM(total_amt) as total_revenue,
        AVG(quantity_ordered) as avg_order_qty
    FROM {{ ref('stg_orders') }}
    GROUP BY product_id
) o ON p.product_id = o.product_id
