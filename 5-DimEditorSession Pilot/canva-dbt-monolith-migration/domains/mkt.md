# Marketing (MKT) Domain Rules

## Business Context
- **Owns**: Campaigns, acquisition, attribution, leads, marketing spend
- **Stakeholders**: Marketing ops, growth marketing, demand gen
- **Data Sensitivity**: Medium (contains lead info, campaign performance)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.MARKETING` | Yes |
| Attribution model | Last-touch | Yes |
| Lead identifier | `lead_id` | Yes |
| Campaign identifier | `campaign_id` | Yes |
| UTM tracking | Available | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_mkt_` | cnf_mkt_campaigns |
| Dimension | `dim_` | dim_campaign, dim_channel |
| Fact | `fact_mkt_` | fact_mkt_campaign_performance |
| Semantic | `sv_mkt_` | sv_mkt_attribution |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_campaign | Type 2 | campaign_id, campaign_name, campaign_type, status |
| dim_channel | Type 1 | channel_id, channel_name, channel_category |
| dim_lead | Type 2 | lead_id, lead_source, lead_status, lead_score |
| dim_utm | Type 1 | utm_source, utm_medium, utm_campaign, utm_content |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_mkt_impressions | One row per ad per day | impressions, clicks, spend |
| fact_mkt_conversions | One row per conversion | conversion_value, is_attributed |
| fact_mkt_leads | One row per lead per stage | stage_duration_days |

## Business Logic Defaults

### Lead Score Tier
```sql
CASE
    WHEN lead_score >= 80 THEN 'HOT'
    WHEN lead_score >= 50 THEN 'WARM'
    WHEN lead_score >= 20 THEN 'COOL'
    ELSE 'COLD'
END
```

### Attribution Windows
| Model | Window |
|-------|--------|
| First-touch | 90 days |
| Last-touch | 30 days |
| Linear | 30 days |
| Time-decay | 30 days, 7-day half-life |

### Channel Categories
| Category | Channels |
|----------|----------|
| Paid | SEM, Paid Social, Display |
| Organic | SEO, Organic Social, Direct |
| Owned | Email, Push, In-app |
| Earned | Referral, PR, Reviews |

### Marketing Metrics
```sql
-- Cost per Acquisition
spend / NULLIF(conversions, 0) AS cpa

-- Return on Ad Spend
revenue / NULLIF(spend, 0) AS roas

-- Click-through Rate
clicks / NULLIF(impressions, 0) AS ctr

-- Conversion Rate
conversions / NULLIF(clicks, 0) AS cvr
```

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | All surrogate keys |
| Not null | 100% | campaign_id, dates |
| Accepted values | channel_category | Paid, Organic, Owned, Earned |
| Non-negative | >= 0 | spend, impressions, clicks |
| Ratio bounds | 0-1 | ctr, cvr |

## Incremental Strategy
- **Default**: Merge on surrogate key
- **Lookback**: 3 days (for attribution updates)
- **Unique key**: campaign_id + date or conversion_id

## Notes
- Attribution data often arrives with delays (up to 7 days)
- Marketing platforms may revise historical data
- Consider storing multiple attribution models in parallel
- UTM parameters should be standardized (lowercase, trimmed)
