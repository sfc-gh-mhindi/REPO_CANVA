# Redundancy Patterns Detection Guide

This document catalogs common redundancy patterns found in DBT monoliths and provides detection strategies for the skill.

---

## 1. Overview

Redundancy in DBT projects manifests in several forms:

| Category | Description | Impact |
|----------|-------------|--------|
| **Model Duplication** | Multiple models producing same/similar output | Wasted compute, maintenance burden |
| **Logic Duplication** | Same SQL patterns repeated across models | Inconsistency risk, hard to update |
| **Column Duplication** | Same data stored with different names | Confusion, join failures |
| **Transformation Duplication** | Same calculations repeated | Divergent results over time |

---

## 2. Model Duplication Patterns

### 2.1 Pattern: Version Suffixes

**Indicator**: Models with `_v1`, `_v2`, `_v3`, `_final`, `_new` suffixes

```
stg_customers_v1.sql
stg_customers_v2.sql
stg_customers_final.sql
```

**Detection Rule**:
```python
if model_name matches pattern "*_v[0-9]" or "*_final" or "*_new":
    flag_as_potential_duplicate()
```

**Resolution**: Consolidate into single model with proper logic

---

### 2.2 Pattern: Overlapping Staging Models

**Indicator**: Multiple staging models for the same conceptual entity

```
stg_customers.sql           # From RAW_CUSTOMERS
stg_customers_legacy.sql    # From RAW_CUSTOMERS_OLD
stg_customers_combined.sql  # Union of both
```

**Detection Rule**:
```
IF multiple models have same prefix "stg_{entity}"
AND they reference same or similar source tables
THEN flag_as_duplicate_staging
```

**Resolution**: Single staging model with union logic (or move union to conformed layer)

---

### 2.3 Pattern: Redundant Intermediate Aggregations

**Indicator**: Multiple intermediate models computing same metrics differently

**Example from TestInput**:
```sql
-- int_customer_360.sql
SELECT customer_id, 
       COUNT(DISTINCT order_id) as total_orders,
       SUM(order_total) as total_revenue

-- int_customer_summary.sql  
SELECT customer_id,
       COUNT(*) as order_count,              -- Same metric, different name
       SUM(order_total) as revenue           -- Same metric, different name

-- int_customer_metrics.sql
SELECT customer_id,
       COUNT(DISTINCT ord_id) as num_orders, -- Same metric, different name
       SUM(total_amt) as total_revenue       -- Same metric, different name
```

**Detection Rule**:
```
IF models have same GROUP BY columns
AND they have similar aggregation functions (COUNT, SUM, AVG)
AND output column names are semantically similar
THEN flag_as_duplicate_aggregation
```

**Resolution**: Single model with canonical column names

---

### 2.4 Pattern: Report Layer Bypassing Marts

**Indicator**: Report models that read directly from raw/staging instead of using marts

```sql
-- rpt_daily_sales.sql (ANTI-PATTERN)
SELECT *
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS  -- Should use fact_orders
```

**Detection Rule**:
```
IF model in reports/ or aggregates/ layer
AND model references source tables directly (not via ref())
THEN flag_as_layer_violation
```

**Resolution**: Reports should only read from metrics layer

---

## 3. Logic Duplication Patterns

### 3.1 Pattern: Repeated CASE Statements

**Indicator**: Same CASE logic with same or similar thresholds appearing multiple times

**Example from TestInput**:
```sql
-- Found in 5 different models with slight variations:

-- Version 1: value_tier
CASE
    WHEN total_revenue > 10000 THEN 'PLATINUM'
    WHEN total_revenue > 5000 THEN 'GOLD'
    WHEN total_revenue > 1000 THEN 'SILVER'
    ELSE 'BRONZE'
END

-- Version 2: segment
CASE
    WHEN revenue >= 10000 THEN 'VIP'
    WHEN revenue >= 5000 THEN 'PREMIUM'
    WHEN revenue >= 1000 THEN 'STANDARD'
    ELSE 'ENTRY'
END

-- Version 3: revenue_tier
CASE
    WHEN SUM(total_amt) > 10000 THEN 'TIER_1'
    WHEN SUM(total_amt) > 5000 THEN 'TIER_2'
    WHEN SUM(total_amt) > 1000 THEN 'TIER_3'
    ELSE 'TIER_4'
END
```

**Detection Rule**:
```
EXTRACT all CASE statements from models
NORMALIZE structure (remove column names, keep thresholds)
HASH the normalized structure
IF same hash appears in 2+ models
THEN flag_as_duplicate_logic(pattern="tier_calculation")
```

**Resolution**: Extract to macro with configurable thresholds

---

### 3.2 Pattern: Repeated Date Calculations

**Indicator**: Same date manipulation logic repeated

**Common Patterns**:
```sql
-- Fiscal year calculation (repeated)
CASE
    WHEN MONTH(date_column) >= 7 THEN YEAR(date_column) + 1
    ELSE YEAR(date_column)
END

-- Days since calculation (repeated)
DATEDIFF('day', some_date, CURRENT_DATE())

-- Date truncation (repeated)
DATE_TRUNC('month', date_column)
```

**Detection Rule**:
```
SCAN for patterns:
- CASE with MONTH() and YEAR() combinations
- DATEDIFF with CURRENT_DATE()
- DATE_TRUNC patterns

IF pattern appears in 2+ models
THEN flag_as_duplicate_logic(pattern="date_calculation")
```

**Resolution**: Extract to date helper macros

---

### 3.3 Pattern: Repeated Aggregation CTEs

**Indicator**: Same CTE structure copied across models

**Example from TestInput**:
```sql
-- This CTE appears in multiple models:
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(order_total) as total_revenue,
        MIN(order_date) as first_order_date,
        MAX(order_date) as last_order_date
    FROM some_orders_table
    GROUP BY customer_id
)
```

**Detection Rule**:
```
EXTRACT all CTEs from models
NORMALIZE (standardize column aliases)
COMPARE CTE structures

IF CTE structure similarity > 80%
AND CTE appears in 2+ models
THEN flag_as_duplicate_cte
```

**Resolution**: Create dedicated intermediate/conformed model for the aggregation

---

### 3.4 Pattern: Repeated Margin/Financial Calculations

**Indicator**: Same financial formulas repeated

```sql
-- Gross margin (repeated)
revenue - cost

-- Margin percentage (repeated)
CASE 
    WHEN revenue = 0 THEN 0
    ELSE (revenue - cost) / revenue * 100
END

-- Net amount (repeated)
gross_amount - discount - tax
```

**Detection Rule**:
```
SCAN for arithmetic patterns involving:
- revenue, cost, margin keywords
- Division with zero-check patterns
- Multiple subtraction chains

IF pattern appears in 2+ models
THEN flag_as_duplicate_logic(pattern="financial_calculation")
```

**Resolution**: Extract to financial calculation macros

---

## 4. Column Duplication Patterns

### 4.1 Pattern: Same Column, Different Names

**Indicator**: Same data with different column aliases across models

**Example from TestInput**:
```
Model               Column Name         Represents
─────────────────────────────────────────────────────
stg_orders          ord_id              Order identifier
stg_orders_v2       order_id            Order identifier
int_orders          order_key           Order identifier

stg_customers_v1    cust_id             Customer identifier
stg_customers_v2    customer_key        Customer identifier
int_customer_360    customer_id         Customer identifier
```

**Detection Rule**:
```
BUILD column catalog across all models
GROUP BY semantic meaning (detect via:
    - Similar name patterns: *_id, *_key, *_code
    - Same source column
    - Same data type + similar values)

IF same semantic column has 2+ different names
THEN flag_as_naming_inconsistency
```

**Resolution**: Standardize to canonical names per naming convention

---

### 4.2 Pattern: Hardcoded vs Calculated Same Value

**Indicator**: Value stored in source AND calculated in models

**Example**:
```sql
-- Source table has:
customer_tier VARCHAR  -- Pre-calculated tier

-- But models also calculate:
CASE
    WHEN lifetime_value > 10000 THEN 'PLATINUM'
    ...
END as customer_tier  -- Calculated tier
```

**Detection Rule**:
```
IF source column name matches calculated column name
AND calculated logic exists in downstream models
THEN flag_as_calculation_conflict
```

**Resolution**: Decide on single source of truth (typically calculate in DBT)

---

## 5. Transformation Duplication Patterns

### 5.1 Pattern: Data Cleansing Repeated

**Indicator**: Same cleansing operations applied multiple times

```sql
-- Found in multiple models:
LOWER(TRIM(email))
INITCAP(first_name)
REGEXP_REPLACE(phone, '[^0-9]', '')
```

**Detection Rule**:
```
SCAN for common cleansing patterns:
- LOWER(TRIM(...))
- UPPER(TRIM(...))
- INITCAP(...)
- REGEXP_REPLACE for phone/special chars
- COALESCE chains

IF pattern appears on same column in 2+ models
THEN flag_as_duplicate_cleansing
```

**Resolution**: Apply cleansing once in conformed layer

---

### 5.2 Pattern: Same Join Logic Repeated

**Indicator**: Same tables joined in same way across models

```sql
-- This join appears in 4 models:
LEFT JOIN dim_customer c ON orders.customer_id = c.customer_id
LEFT JOIN dim_product p ON orders.product_id = p.product_id
LEFT JOIN dim_date d ON DATE(orders.order_date) = d.date_day
```

**Detection Rule**:
```
EXTRACT all JOIN clauses
NORMALIZE (standardize aliases)

IF same join pattern (tables + conditions) appears in 3+ models
THEN flag_as_repeated_join_pattern
```

**Resolution**: Consider whether this join pattern should be a single model

---

## 6. Structural Duplication Patterns

### 6.1 Pattern: Source Referenced Multiple Ways

**Indicator**: Same source table accessed via different methods

```sql
-- Model A: Hardcoded reference
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS

-- Model B: Different hardcoded reference
FROM RAW.RAW_CUSTOMERS

-- Model C: Using source (correct)
FROM {{ source('raw', 'raw_customers') }}
```

**Detection Rule**:
```
EXTRACT all FROM clauses
NORMALIZE table references

IF same table accessed via 2+ different reference methods
THEN flag_as_inconsistent_source_reference
```

**Resolution**: All references should use `{{ source() }}`

---

### 6.2 Pattern: Union Logic in Wrong Layer

**Indicator**: UNION operations in staging instead of conformed layer

```sql
-- stg_customers_combined.sql (WRONG LAYER)
SELECT * FROM raw_customers_v1
UNION ALL
SELECT * FROM raw_customers_v2
```

**Detection Rule**:
```
IF model in staging layer
AND model contains UNION or UNION ALL
THEN flag_as_union_in_staging
```

**Resolution**: Move union logic to conformed layer

---

## 7. Detection Summary Checklist

When analyzing a model set, check for:

### Model Level
- [ ] Version suffix patterns (_v1, _v2, _final)
- [ ] Multiple staging for same entity
- [ ] Overlapping intermediate aggregations
- [ ] Reports bypassing marts
- [ ] Direct raw table access in non-staging

### Logic Level
- [ ] Repeated CASE statements (tiers, categories)
- [ ] Repeated date calculations (fiscal, datediff)
- [ ] Repeated aggregation CTEs
- [ ] Repeated financial calculations

### Column Level
- [ ] Same data, different names
- [ ] Stored vs calculated conflicts
- [ ] Inconsistent data types for same concept

### Transformation Level
- [ ] Repeated cleansing operations
- [ ] Repeated join patterns
- [ ] Repeated filter conditions

### Structural Level
- [ ] Inconsistent source references
- [ ] Union in wrong layer
- [ ] Missing ref() usage

---

## 8. Redundancy Scoring

Score each model for redundancy severity:

| Factor | Points | Description |
|--------|--------|-------------|
| Has version suffix | +5 | Likely duplicate |
| Shares >70% sources with another model | +10 | High overlap |
| Contains CASE also in other models | +3 per | Repeated logic |
| Hardcoded source reference | +2 | Bad practice |
| Bypasses layer hierarchy | +5 | Architecture violation |
| Same aggregation as another model | +8 | Definite duplicate |

**Score Interpretation**:
- 0-5: Low redundancy (minimal action needed)
- 6-15: Medium redundancy (consolidation recommended)
- 16+: High redundancy (consolidation required)

---

## 9. Example Analysis Output

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      REDUNDANCY ANALYSIS REPORT                              │
│                      Domain: Product Experience                              │
│                      Models Analyzed: 8                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ MODEL DUPLICATION                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ Group 1: Customer Staging (SEVERITY: HIGH)                                  │
│   - stg_customers_v1, stg_customers_v2, stg_customers_combined             │
│   - Source overlap: 100%                                                    │
│   - Column overlap: 85%                                                     │
│   → CONSOLIDATE TO: cnf_customers                                          │
│                                                                             │
│ Group 2: Customer Aggregations (SEVERITY: HIGH)                            │
│   - int_customer_360, int_customer_summary, int_customer_metrics           │
│   - Same aggregations with different names                                 │
│   → CONSOLIDATE TO: dim_customer                                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ LOGIC DUPLICATION                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ Pattern 1: Customer Tier CASE (OCCURRENCES: 5)                              │
│   - int_customer_360: value_tier                                            │
│   - int_customer_summary: segment                                           │
│   - int_customer_metrics: revenue_tier                                      │
│   - dim_customers: lifecycle_tier, revenue_segment, metrics_tier           │
│   → EXTRACT TO: {{ calculate_customer_tier() }}                            │
│                                                                             │
│ Pattern 2: Order Value CASE (OCCURRENCES: 3)                                │
│   - stg_orders: order_value_tier                                            │
│   - stg_orders_v2: value_segment                                            │
│   - rpt_daily_sales: order_size                                             │
│   → EXTRACT TO: {{ calculate_order_tier() }}                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ ANTI-PATTERNS                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ Hardcoded References: 8 instances                                           │
│   - int_customer_360: DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1               │
│   - int_customer_360: DBT_REFACTOR_TEST.RAW.RAW_ORDERS                     │
│   - stg_orders: DBT_REFACTOR_TEST.RAW.RAW_ORDERS                           │
│   - ... (5 more)                                                            │
│   → REPLACE WITH: {{ source('raw', 'table_name') }}                        │
│                                                                             │
│ Layer Violations: 4 instances                                               │
│   - int_customer_360 reads RAW tables (should use staging)                 │
│   - rpt_daily_sales reads RAW tables (should use marts)                    │
│   - ... (2 more)                                                            │
│   → ENFORCE: Proper layer dependencies                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ SUMMARY                                                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ Total Redundancy Score: 67 (HIGH)                                           │
│                                                                             │
│ Estimated Impact:                                                           │
│   - Models: 8 → 3 (62.5% reduction)                                        │
│   - SQL Lines: ~450 → ~180 (60% reduction)                                 │
│   - Macros to create: 2                                                    │
│   - Maintenance effort: Significantly reduced                              │
└─────────────────────────────────────────────────────────────────────────────┘
```
