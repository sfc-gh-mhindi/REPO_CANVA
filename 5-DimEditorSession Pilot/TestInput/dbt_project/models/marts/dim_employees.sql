-- ANTI-PATTERN: Employee dimension with embedded hierarchy
SELECT DISTINCT
    employee_id,
    employee_first_name || ' ' || employee_last_name as employee_name,
    employee_first_name,
    employee_last_name,
    employee_department,
    employee_title,
    employee_hire_date,
    employee_manager_id,
    employee_manager_name
FROM {{ ref('stg_employee_sales') }}
WHERE employee_id IS NOT NULL
