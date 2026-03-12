-- ANTI-PATTERN: Marketing report with complex embedded logic
SELECT
    c.campaign_id,
    c.campaign_name,
    c.campaign_type,
    c.campaign_status,
    c.start_date,
    c.end_date,
    c.budget_amount,
    c.budget_spent,
    c.impressions,
    c.clicks,
    c.conversions,
    c.revenue_attributed,
    c.cost_per_click,
    c.cost_per_conversion,
    c.return_on_ad_spend,
    -- Derived metrics
    CASE WHEN c.impressions > 0 THEN c.clicks / c.impressions ELSE 0 END as ctr,
    CASE WHEN c.clicks > 0 THEN c.conversions / c.clicks ELSE 0 END as conversion_rate,
    CASE WHEN c.budget_amount > 0 THEN c.budget_spent / c.budget_amount ELSE 0 END as budget_utilization,
    -- Campaign grade
    CASE
        WHEN c.return_on_ad_spend >= 5 THEN 'A'
        WHEN c.return_on_ad_spend >= 3 THEN 'B'
        WHEN c.return_on_ad_spend >= 1 THEN 'C'
        ELSE 'D'
    END as campaign_grade
FROM {{ ref('stg_campaigns') }} c
