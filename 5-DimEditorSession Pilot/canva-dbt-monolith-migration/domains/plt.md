# Pilot (PLT) Domain Rules

## Business Context
- **Owns**: Experimental features, A/B tests, beta programs, feature flags
- **Stakeholders**: Product teams, data science, experimentation platform
- **Data Sensitivity**: Medium (contains experiment assignments, user behavior)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.EXPERIMENTATION` | Yes |
| Assignment grain | User per experiment | Yes |
| User identifier | `user_id` | Yes |
| Experiment identifier | `experiment_id` | Yes |
| Variant identifier | `variant_id` | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_plt_` | cnf_plt_experiments |
| Dimension | `dim_` | dim_experiment, dim_variant |
| Fact | `fact_plt_` | fact_plt_assignments |
| Semantic | `sv_plt_` | sv_plt_experimentation |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_experiment | Type 2 | experiment_id, experiment_name, hypothesis, owner, status |
| dim_variant | Type 1 | variant_id, variant_name, is_control, traffic_pct |
| dim_metric | Type 1 | metric_id, metric_name, metric_type, direction |
| dim_user_segment | Type 1 | segment_id, segment_name, segment_criteria |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_plt_assignments | One row per user per experiment | assignment_date, is_exposed |
| fact_plt_exposures | One row per exposure event | exposure_count |
| fact_plt_metric_values | One row per user per experiment per metric | metric_value |
| fact_plt_experiment_results | One row per experiment per variant per day | sample_size, metric_sum, metric_sum_sq |

## Business Logic Defaults

### Experiment Status
```sql
CASE
    WHEN end_date < CURRENT_DATE THEN 'COMPLETED'
    WHEN start_date > CURRENT_DATE THEN 'SCHEDULED'
    WHEN is_paused = TRUE THEN 'PAUSED'
    ELSE 'RUNNING'
END
```

### Statistical Significance
```sql
-- Z-score for proportion comparison
(treatment_rate - control_rate) / 
SQRT((pooled_rate * (1 - pooled_rate)) * (1/treatment_n + 1/control_n)) AS z_score

-- Significant if |z_score| > 1.96 (95% confidence)
ABS(z_score) > 1.96 AS is_significant
```

### Minimum Sample Size
| Metric Type | Min Per Variant |
|-------------|-----------------|
| Conversion (binary) | 1,000 |
| Revenue (continuous) | 5,000 |
| Engagement (count) | 2,500 |

### Experiment Phases
| Phase | Description |
|-------|-------------|
| RAMP | Traffic gradually increasing |
| FULL | Full traffic allocation |
| HOLDOUT | Control holdout for long-term effects |
| SHIPPED | Winner deployed to 100% |

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | User + experiment combination |
| Not null | 100% | user_id, experiment_id, variant_id |
| Accepted values | status | SCHEDULED, RUNNING, PAUSED, COMPLETED |
| Referential | variant → experiment | Foreign key integrity |
| Sample ratio mismatch | < 1% deviation | Traffic allocation |

## Incremental Strategy
- **Default**: Merge on surrogate key
- **Lookback**: 1 day
- **Unique key**: user_id + experiment_id

## Notes
- Experiment data requires strict consistency (no double-counting)
- Assignment must be deterministic (same user → same variant)
- Watch for sample ratio mismatch (SRM) as data quality signal
- Historical experiment data valuable for meta-analysis
- Consider pre-experiment vs post-experiment metrics for novelty effects
- Segment-level analysis requires sufficient sample sizes per segment
