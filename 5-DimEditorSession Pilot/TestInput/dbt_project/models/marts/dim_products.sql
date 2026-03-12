-- ANTI-PATTERN: Combines two product summaries with different structures
SELECT
    COALESCE(pp.product_id, ps.product_id) as product_id,
    COALESCE(pp.sku, ps.sku) as sku,
    COALESCE(pp.product_name, ps.product_name) as product_name,
    COALESCE(pp.category, ps.category) as category,
    pp.subcategory,
    COALESCE(pp.brand, ps.brand) as brand,
    pp.supplier_name,
    COALESCE(pp.retail_price, ps.retail_price) as retail_price,
    COALESCE(pp.cost_price, ps.cost_price) as cost_price,
    COALESCE(pp.margin, ps.margin) as margin,
    COALESCE(pp.margin_pct, ps.margin_pct) as margin_pct,
    pp.stock as current_stock,
    pp.reorder_point,
    pp.is_active,
    pp.is_featured,
    pp.is_clearance,
    COALESCE(pp.units_sold_all_time, ps.total_units_sold) as units_sold,
    COALESCE(pp.total_revenue, ps.total_revenue) as total_revenue,
    COALESCE(pp.order_count, ps.order_count) as order_count,
    -- Category for reporting
    CASE
        WHEN COALESCE(pp.total_revenue, ps.total_revenue, 0) > 100000 THEN 'STAR'
        WHEN COALESCE(pp.total_revenue, ps.total_revenue, 0) > 50000 THEN 'PERFORMER'
        WHEN COALESCE(pp.total_revenue, ps.total_revenue, 0) > 10000 THEN 'STEADY'
        ELSE 'UNDERPERFORMER'
    END as performance_category
FROM {{ ref('int_product_performance') }} pp
FULL OUTER JOIN {{ ref('int_product_summary') }} ps ON pp.product_id = ps.product_id
