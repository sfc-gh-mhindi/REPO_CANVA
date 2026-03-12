-- ANTI-PATTERN: Joins multiple versions of same staging models
-- ANTI-PATTERN: Massive query with no clear purpose
WITH orders_v1 AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
orders_v2 AS (
    SELECT * FROM {{ ref('stg_orders_v2') }}
),
orders_completed AS (
    SELECT * FROM {{ ref('stg_orders_completed') }}
),
products AS (
    SELECT * FROM {{ ref('stg_products') }}
)
SELECT
    o1.ord_id as order_id,
    o1.ord_dt as order_date,
    o1.cust_id as customer_id,
    o1.total_amt as order_amount,
    o1.order_value_tier,
    o2.value_segment,
    oc.service_tier,
    p.product_name,
    p.category_l1_name as category,
    p.brand_name as brand,
    p.retail_price,
    p.cost_price,
    p.retail_price - p.cost_price as gross_margin,
    -- ANTI-PATTERN: Hardcoded date ranges
    CASE
        WHEN o1.ord_dt >= '2024-01-01' THEN 'Q1_2024'
        WHEN o1.ord_dt >= '2023-10-01' THEN 'Q4_2023'
        WHEN o1.ord_dt >= '2023-07-01' THEN 'Q3_2023'
        ELSE 'EARLIER'
    END as fiscal_quarter
FROM orders_v1 o1
LEFT JOIN orders_v2 o2 ON o1.ord_id = o2.order_id
LEFT JOIN orders_completed oc ON o1.ord_id = oc.id
LEFT JOIN products p ON o1.product_id = p.product_id
