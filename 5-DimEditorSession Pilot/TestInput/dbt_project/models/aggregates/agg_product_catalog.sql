-- ANTI-PATTERN: Product aggregates with duplicate logic
SELECT
    category_l1_name as category,
    category_l2_name as subcategory,
    brand_name as brand,
    COUNT(DISTINCT product_id) as product_count,
    SUM(current_stock_qty) as total_stock,
    AVG(retail_price) as avg_price,
    AVG(cost_price) as avg_cost,
    AVG(retail_price - cost_price) as avg_margin,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_products,
    SUM(CASE WHEN is_clearance = TRUE THEN 1 ELSE 0 END) as clearance_products
FROM DBT_REFACTOR_TEST.RAW.RAW_PRODUCTS_FLAT
GROUP BY 1, 2, 3
