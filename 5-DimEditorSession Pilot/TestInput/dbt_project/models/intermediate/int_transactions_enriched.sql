-- ANTI-PATTERN: Combines transactions with orders redundantly
SELECT
    t.transaction_id,
    t.transaction_date,
    t.type as transaction_type,
    t.amount as transaction_amount,
    t.net_amount,
    t.order_id,
    o.ord_dt as order_date,
    o.status as order_status,
    o.total_amt as order_total,
    t.customer_id,
    t.customer_name,
    t.customer_email,
    c.city as customer_city,
    c.state as customer_state,
    t.product_id,
    t.product_name,
    t.category as product_category,
    t.unit_price,
    t.quantity,
    t.payment_method,
    t.payment_processor,
    t.store_id,
    t.store_name,
    t.channel_type
FROM {{ ref('stg_transactions') }} t
LEFT JOIN {{ ref('stg_orders') }} o ON t.order_id = o.ord_id
LEFT JOIN {{ ref('stg_customers_v1') }} c ON t.customer_id = c.customer_id
