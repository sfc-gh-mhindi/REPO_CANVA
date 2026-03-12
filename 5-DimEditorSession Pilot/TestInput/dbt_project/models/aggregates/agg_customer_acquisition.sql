-- ANTI-PATTERN: Customer aggregates duplicating intermediate
SELECT
    DATE_TRUNC('month', registration_date) as registration_month,
    acquisition_source,
    COUNT(DISTINCT cust_id) as new_customers,
    AVG(total_spend) as avg_lifetime_value,
    AVG(total_orders) as avg_orders,
    SUM(total_spend) as total_cohort_revenue
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1
GROUP BY 1, 2
