# Product Experience (PEX) Domain Rules

## Business Context
- **Owns**: User engagement, product health, feature usage, user journeys
- **Stakeholders**: Product managers, UX researchers, growth teams
- **Data Sensitivity**: Medium (contains user behavior, no PII by default)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.PRODUCT` | Yes |
| Event grain | User action level | Yes |
| User identifier | `user_id` | Yes |
| Timestamp field | `event_timestamp` | Yes |
| Session tracking | Available via `session_id` | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_pex_` | cnf_pex_user_events |
| Dimension | `dim_` | dim_user, dim_feature |
| Fact | `fact_pex_` | fact_pex_engagement |
| Semantic | `sv_pex_` | sv_pex_product_analytics |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_user | Type 2 | user_id, signup_date, user_tier, account_type |
| dim_feature | Type 1 | feature_id, feature_name, feature_area, release_date |
| dim_device | Type 1 | device_type, os, browser, app_version |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_pex_sessions | One row per session | session_duration, page_views, actions_count |
| fact_pex_feature_usage | One row per feature per user per day | usage_count, time_spent |
| fact_pex_events | One row per event | event_count (always 1) |

## Business Logic Defaults

### User Tier Calculation
```sql
CASE
    WHEN days_active_l30 >= 20 THEN 'POWER'
    WHEN days_active_l30 >= 10 THEN 'ACTIVE'
    WHEN days_active_l30 >= 1 THEN 'CASUAL'
    ELSE 'DORMANT'
END
```

### Engagement Score
```sql
(session_count * 1.0) + (feature_usage_count * 0.5) + (days_active * 2.0)
```

### Retention Windows
| Window | Days |
|--------|------|
| Daily Active | 1 |
| Weekly Active | 7 |
| Monthly Active | 30 |

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | All surrogate keys |
| Not null | 100% | user_id, event_timestamp |
| Freshness | < 24 hours | fact tables |
| Row count | > 0 | All tables |

## Incremental Strategy
- **Default**: Merge on surrogate key
- **Lookback**: 3 days (for late-arriving events)
- **Unique key**: Composite of natural keys + date

## Notes
- PEX data tends to be high volume (billions of events)
- Prioritize incremental models over full refresh
- Consider clustering on `event_date` and `user_id`
