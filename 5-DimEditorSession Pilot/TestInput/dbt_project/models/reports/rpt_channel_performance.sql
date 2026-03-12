-- ANTI-PATTERN: Report that re-aggregates transactions
SELECT
    DATE_TRUNC('day', transaction_date) as txn_date,
    channel_type,
    payment_method,
    COUNT(DISTINCT transaction_id) as transaction_count,
    COUNT(DISTINCT CASE WHEN transaction_type = 'SALE' THEN transaction_id END) as sales_count,
    COUNT(DISTINCT CASE WHEN transaction_type = 'REFUND' THEN transaction_id END) as refund_count,
    SUM(CASE WHEN transaction_type = 'SALE' THEN transaction_amount ELSE 0 END) as gross_sales,
    SUM(CASE WHEN transaction_type = 'REFUND' THEN transaction_amount ELSE 0 END) as refunds,
    SUM(net_amount) as net_revenue,
    COUNT(DISTINCT customer_id) as unique_customers
FROM {{ ref('fct_transactions') }}
GROUP BY 1, 2, 3
