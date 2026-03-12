-- ANTI-PATTERN: Product analysis duplicating multiple models
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.retail_price,
    p.cost_price,
    p.margin,
    p.margin_pct,
    p.units_sold,
    p.total_revenue,
    p.order_count,
    p.performance_category,
    -- Inventory info
    p.current_stock,
    -- Calculate stock coverage
    CASE
        WHEN p.units_sold > 0 THEN p.current_stock / (p.units_sold / 365.0)
        ELSE 999
    END as days_of_stock,
    -- ABC classification
    CASE
        WHEN p.total_revenue > 100000 THEN 'A'
        WHEN p.total_revenue > 50000 THEN 'B'
        ELSE 'C'
    END as abc_class
FROM {{ ref('dim_products') }} p
