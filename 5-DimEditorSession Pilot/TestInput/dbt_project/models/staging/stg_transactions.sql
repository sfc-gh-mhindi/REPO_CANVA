-- ANTI-PATTERN: Direct reference to raw table
-- ANTI-PATTERN: Inconsistent with other staging models
SELECT
    txn_id as transaction_id,
    txn_timestamp as transaction_date,
    txn_type as type,
    txn_amount as amount,
    txn_tax_amount as tax,
    txn_fee as fee,
    txn_net as net_amount,
    related_order_id as order_id,
    cust_id as customer_id,
    cust_name as customer_name,
    cust_email_address as customer_email,
    prod_id as product_id,
    prod_description as product_name,
    prod_category_name as category,
    prod_unit_cost as unit_price,
    prod_qty as quantity,
    pay_method as payment_method,
    pay_processor as payment_processor,
    store_id,
    store_name,
    channel_type,
    created_timestamp
FROM DBT_REFACTOR_TEST.RAW.RAW_TRANSACTIONS
