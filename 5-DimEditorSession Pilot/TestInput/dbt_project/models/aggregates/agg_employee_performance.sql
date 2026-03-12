-- ANTI-PATTERN: Employee performance duplicating stg_employee_sales
SELECT
    employee_id,
    employee_first_name || ' ' || employee_last_name as employee_name,
    employee_department,
    store_name,
    store_region,
    DATE_TRUNC('month', sale_date) as month,
    COUNT(DISTINCT order_id) as orders_sold,
    SUM(order_total) as total_sales,
    SUM(commission_amount) as total_commission,
    AVG(quota_attainment_pct) as avg_quota_attainment,
    MAX(performance_tier) as performance_tier
FROM DBT_REFACTOR_TEST.RAW.RAW_EMPLOYEE_SALES
GROUP BY 1, 2, 3, 4, 5, 6
