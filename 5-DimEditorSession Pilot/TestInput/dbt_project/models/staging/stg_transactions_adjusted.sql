-- ANTI-PATTERN: Duplicate transactions staging
SELECT
    txn_id,
    txn_timestamp,
    txn_type,
    txn_amount,
    txn_net,
    related_order_id,
    cust_id,
    cust_name,
    cust_email_address,
    prod_id,
    store_id,
    channel_type,
    -- ANTI-PATTERN: Same calculation done differently
    CASE txn_type
        WHEN 'SALE' THEN txn_amount
        WHEN 'REFUND' THEN -1 * txn_amount
        ELSE 0
    END as adjusted_amount
FROM DBT_REFACTOR_TEST.RAW.RAW_TRANSACTIONS
WHERE txn_type IN ('SALE', 'REFUND')
