-- ANTI-PATTERN: Duplicate products staging with different columns
SELECT
    product_id as id,
    sku as product_sku,
    product_name as name,
    category_l1_name as category,
    category_l2_name as subcategory,
    brand_name as brand,
    retail_price as price,
    cost_price as cost,
    retail_price - cost_price as margin,
    (retail_price - cost_price) / NULLIF(retail_price, 0) * 100 as margin_pct,
    is_active,
    current_stock_qty as stock
FROM DBT_REFACTOR_TEST.RAW.RAW_PRODUCTS_FLAT
WHERE is_active = TRUE
