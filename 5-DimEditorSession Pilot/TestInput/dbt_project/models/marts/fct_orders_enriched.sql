-- ANTI-PATTERN: Yet another orders fact with different structure
SELECT
    oe.order_id,
    oe.order_date,
    oe.customer_id,
    oe.order_amount,
    oe.order_value_tier,
    oe.value_segment,
    oe.service_tier,
    oe.product_name,
    oe.category,
    oe.brand,
    oe.retail_price,
    oe.cost_price,
    oe.gross_margin,
    oe.fiscal_quarter,
    c.full_name as customer_name,
    c.email as customer_email,
    c.customer_lifecycle_stage,
    c.value_tier as customer_tier
FROM {{ ref('int_orders_enriched') }} oe
LEFT JOIN {{ ref('int_customer_360') }} c ON oe.customer_id = c.customer_id
