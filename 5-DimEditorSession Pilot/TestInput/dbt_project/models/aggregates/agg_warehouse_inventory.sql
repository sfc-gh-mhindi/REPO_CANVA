-- ANTI-PATTERN: Inventory aggregates with warehouse duplication
SELECT
    warehouse_id,
    warehouse_name,
    warehouse_city,
    warehouse_state,
    DATE_TRUNC('month', log_timestamp) as month,
    COUNT(DISTINCT log_id) as movement_count,
    SUM(CASE WHEN movement_type = 'RECEIPT' THEN quantity_change ELSE 0 END) as receipts,
    SUM(CASE WHEN movement_type = 'SALE' THEN ABS(quantity_change) ELSE 0 END) as sales,
    SUM(CASE WHEN movement_type = 'RETURN' THEN quantity_change ELSE 0 END) as returns,
    SUM(CASE WHEN movement_type = 'ADJUSTMENT' THEN quantity_change ELSE 0 END) as adjustments,
    SUM(total_cost) as total_inventory_value
FROM DBT_REFACTOR_TEST.RAW.RAW_INVENTORY_LOG
GROUP BY 1, 2, 3, 4, 5
