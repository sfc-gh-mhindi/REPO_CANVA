-- ANTI-PATTERN: Date dimension built inline with limited dates
SELECT
    date_day as date_key,
    date_day,
    DAYOFWEEK(date_day) as day_of_week,
    DAYNAME(date_day) as day_name,
    DAY(date_day) as day_of_month,
    WEEKOFYEAR(date_day) as week_of_year,
    MONTH(date_day) as month_number,
    MONTHNAME(date_day) as month_name,
    QUARTER(date_day) as quarter,
    YEAR(date_day) as year,
    CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END as is_weekend,
    -- Hardcoded fiscal calendar
    CASE
        WHEN MONTH(date_day) >= 7 THEN YEAR(date_day) + 1
        ELSE YEAR(date_day)
    END as fiscal_year
FROM (
    SELECT DATEADD('day', seq4(), '2020-01-01'::DATE) as date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 2000))
)
