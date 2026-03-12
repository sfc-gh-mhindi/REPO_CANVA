# Analysis Workflow

This document defines the step-by-step process the skill follows to analyze existing DBT models and design the target architecture.

---

## 1. Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              MIGRATION ANALYSIS WORKFLOW                                 │
└─────────────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
    │   STEP 1     │     │   STEP 2     │     │   STEP 3     │     │   STEP 4     │
    │   Intake     │ ──► │  Discovery   │ ──► │  Analysis    │ ──► │   Design     │
    └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
          │                    │                    │                    │
          ▼                    ▼                    ▼                    ▼
    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
    │ - Domain     │     │ - Lineage    │     │ - Redundancy │     │ - Conformed  │
    │ - Models     │     │ - Sources    │     │ - Anti-       │     │ - Metrics    │
    │ - Context    │     │ - Columns    │     │   patterns   │     │ - Semantic   │
    └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                                                                          │
    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐           │
    │   STEP 7     │     │   STEP 6     │     │   STEP 5     │           │
    │  Validate    │ ◄── │  Generate    │ ◄── │   Macros     │ ◄─────────┘
    └──────────────┘     └──────────────┘     └──────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
    │ - Compile    │     │ - Models     │     │ - Extract    │
    │ - Test       │     │ - Tests      │     │ - Document   │
    │ - Document   │     │ - Docs       │     │ - Implement  │
    └──────────────┘     └──────────────┘     └──────────────┘
```

---

## 2. Step 1: Intake

### 2.1 Purpose
Gather all inputs and establish context for the migration.

### 2.2 Required Inputs

| Input | Source | Required |
|-------|--------|----------|
| Target Domain | User selection | ✅ Yes |
| DBT Model Files | User provides SQL files or paths | ✅ Yes |
| Source Table DDLs | User provides or describe from Snowflake | ✅ Yes |
| Business Context | User description | ⚪ Optional |

### 2.3 Domain Selection

Prompt user to select one of the supported domains:

| Domain | Code | Description |
|--------|------|-------------|
| Product Experience | `pex` | User engagement, product health, feature usage |
| Monetisation | `mon` | Revenue, billing, subscriptions, payments |
| Marketing | `mkt` | Campaigns, acquisition, attribution |
| IT | `it` | Infrastructure, systems, operations |
| Print | `prt` | Print services, fulfillment, production |
| Pilot | `plt` | Experimental features, A/B tests |

### 2.4 Model Collection

For each model provided, extract:
- Model name
- File path
- SQL content
- Configuration (if in YAML)

### 2.5 Intake Checklist

- [ ] Domain selected
- [ ] At least one DBT model provided
- [ ] Source table information available
- [ ] Business context understood (if provided)

---

## 3. Step 2: Discovery

### 3.1 Purpose
Map the complete landscape of models, dependencies, and sources.

### 3.2 Lineage Mapping

For each model, extract:

```
┌─────────────────────────────────────────────────────────────────┐
│ MODEL: stg_customers_v1                                          │
├─────────────────────────────────────────────────────────────────┤
│ UPSTREAM (Sources):                                              │
│   - DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1 (hardcoded)         │
│                                                                  │
│ DOWNSTREAM (Dependents):                                         │
│   - int_customer_summary (via ref)                              │
│   - int_customer_360 (direct raw access - issue)                │
│                                                                  │
│ COLUMNS PRODUCED:                                                │
│   - customer_id, first_name, last_name, email, ...              │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Source Table Inventory

| Source Table | Models Using It | Access Method |
|--------------|-----------------|---------------|
| RAW_CUSTOMERS_V1 | stg_customers_v1, int_customer_360 | Hardcoded |
| RAW_CUSTOMERS_V2 | stg_customers_v2, int_customer_metrics | Hardcoded |
| RAW_ORDERS | stg_orders, int_customer_360 | Hardcoded |

### 3.4 Column Catalog

Track all columns across models:

| Column Name | Found In | Data Type | Transformation |
|-------------|----------|-----------|----------------|
| customer_id | 5 models | VARCHAR | Various aliases: cust_id, customer_key |
| email | 4 models | VARCHAR | Some apply LOWER/TRIM |
| total_orders | 3 models | INT | Calculated differently |

### 3.5 Discovery Checklist

- [ ] All model dependencies mapped
- [ ] All source tables identified
- [ ] All columns catalogued
- [ ] Dependency graph built

---

## 4. Step 3: Analysis

### 4.1 Purpose
Identify issues, redundancies, and anti-patterns that need to be resolved.

### 4.2 Redundancy Detection

#### 4.2.1 Duplicate Model Detection

Look for models that:
- Use the same source table(s)
- Produce similar columns
- Have similar names (v1, v2, _combined, _final)

**Detection Pattern**:
```
IF models share >70% source columns AND produce >50% same output columns
THEN flag as POTENTIAL_DUPLICATE
```

**Example Finding**:
```
┌─────────────────────────────────────────────────────────────────┐
│ REDUNDANCY: Duplicate Customer Staging                          │
├─────────────────────────────────────────────────────────────────┤
│ Models: stg_customers_v1, stg_customers_v2, stg_customers_combined │
│ Source Overlap: 100% (both read customer tables)                │
│ Column Overlap: 85%                                              │
│ Recommendation: Consolidate into single cnf_customers           │
└─────────────────────────────────────────────────────────────────┘
```

#### 4.2.2 Duplicate Logic Detection

Scan SQL for repeated patterns:

| Pattern Type | Detection Method | Example |
|--------------|------------------|---------|
| CASE statements | Hash of CASE structure | Customer tier logic |
| Aggregations | Same GROUP BY + aggregates | Order summaries |
| Date calculations | DATEDIFF, DATE_TRUNC patterns | Days since, fiscal periods |
| Join patterns | Same table joins | Customer-order joins |

**Example Finding**:
```
┌─────────────────────────────────────────────────────────────────┐
│ REDUNDANCY: Repeated Tier Logic                                  │
├─────────────────────────────────────────────────────────────────┤
│ Pattern: Customer tier CASE statement                           │
│ Found in: 5 models                                               │
│ Variations: 3 (different thresholds/names)                      │
│ Recommendation: Extract to calculate_customer_tier macro        │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 Anti-Pattern Detection

#### 4.3.1 Source Reference Issues

```sql
-- ANTI-PATTERN: Hardcoded database reference
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1

-- SHOULD BE:
FROM {{ source('raw', 'raw_customers_v1') }}
```

#### 4.3.2 Layer Violations

| Violation | Description | Example |
|-----------|-------------|---------|
| Raw in Reports | Report model reads raw table | rpt_sales reads RAW_ORDERS |
| Skipped Staging | Intermediate reads raw directly | int_customer_360 |
| Metrics in Dims | Aggregated values in dimension | dim_customer.total_orders |

#### 4.3.3 Naming Inconsistencies

| Issue | Example | Impact |
|-------|---------|--------|
| Same concept, different names | cust_id, customer_id, CustomerID | Confusion |
| Different concepts, same name | order_total (gross vs net) | Data quality |
| Non-descriptive names | v1, v2, temp, final | Maintenance |

### 4.4 Analysis Output

Generate analysis report:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANALYSIS SUMMARY                              │
├─────────────────────────────────────────────────────────────────┤
│ Models Analyzed: 8                                               │
│ Source Tables: 6                                                 │
│ Unique Columns: 45                                               │
├─────────────────────────────────────────────────────────────────┤
│ ISSUES FOUND:                                                    │
│   - Duplicate Models: 3 groups                                  │
│   - Repeated Logic: 5 patterns                                  │
│   - Hardcoded References: 8 instances                           │
│   - Layer Violations: 4 instances                               │
│   - Naming Inconsistencies: 12 columns                          │
├─────────────────────────────────────────────────────────────────┤
│ ESTIMATED REDUCTION:                                             │
│   - Models: 8 → 3 (62.5% reduction)                             │
│   - Lines of SQL: 450 → 180 (60% reduction)                     │
└─────────────────────────────────────────────────────────────────┘
```

### 4.5 Analysis Checklist

- [ ] Duplicate models identified
- [ ] Duplicate logic patterns found
- [ ] Anti-patterns documented
- [ ] Naming issues catalogued
- [ ] Analysis summary generated

---

## 5. Step 4: Design

### 5.1 Purpose
Design the target architecture following the three-layer model.

### 5.2 Entity Identification

From the analyzed models, identify core entities:

| Entity | Source Tables | Current Models | Target |
|--------|---------------|----------------|--------|
| Customer | RAW_CUSTOMERS_V1, V2 | stg_customers_*, int_customer_* | cnf_customers, dim_customer |
| Order | RAW_ORDERS | stg_orders_* | cnf_orders, fact_orders |
| Product | RAW_PRODUCTS | stg_products | cnf_products, dim_product |

### 5.3 Layer Design

#### 5.3.1 Conformed Layer Design

For each entity, design conformed model:

```
┌─────────────────────────────────────────────────────────────────┐
│ CONFORMED MODEL: cnf_customers                                   │
├─────────────────────────────────────────────────────────────────┤
│ Sources: raw.raw_customers_v1, raw.raw_customers_v2             │
│ Grain: One row per customer (deduplicated)                      │
│ Key: customer_id                                                 │
│                                                                  │
│ Transformations:                                                 │
│   - Union V1 and V2 sources                                     │
│   - Deduplicate by customer_id (prefer most recent)             │
│   - Standardize: LOWER(email), INITCAP(names)                   │
│   - Add SCD2 columns: valid_from, valid_to, is_current          │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.2 Metrics Layer Design

Design dimensions and facts:

**Dimension Design**:
```
┌─────────────────────────────────────────────────────────────────┐
│ DIMENSION: dim_customer                                          │
├─────────────────────────────────────────────────────────────────┤
│ Source: cnf_customers + aggregated metrics                      │
│ SCD Type: 2                                                      │
│ Key: customer_key (surrogate)                                   │
│                                                                  │
│ Attributes:                                                      │
│   - Descriptive: name, email, city, state, country              │
│   - Categorical: customer_tier, lifecycle_stage                 │
│   - Flags: is_active                                            │
│                                                                  │
│ Enrichments:                                                     │
│   - Order metrics (from orders aggregation)                     │
│   - Support metrics (from tickets aggregation)                  │
│   - Session metrics (from clickstream aggregation)              │
└─────────────────────────────────────────────────────────────────┘
```

**Fact Design**:
```
┌─────────────────────────────────────────────────────────────────┐
│ FACT: fact_orders                                                │
├─────────────────────────────────────────────────────────────────┤
│ Grain: One row per order line item                              │
│ Key: order_line_key (surrogate)                                 │
│                                                                  │
│ Foreign Keys:                                                    │
│   - customer_key → dim_customer                                 │
│   - product_key → dim_product                                   │
│   - date_key → dim_date                                         │
│                                                                  │
│ Degenerate Dimensions:                                           │
│   - order_id, order_number                                      │
│                                                                  │
│ Measures:                                                        │
│   - quantity, unit_price, line_amount                           │
│   - discount_amount, tax_amount                                 │
│   - margin_amount, margin_pct                                   │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.3 Semantic Layer Design

Design semantic views:

```
┌─────────────────────────────────────────────────────────────────┐
│ SEMANTIC VIEW: sv_pex_customer_analytics                         │
├─────────────────────────────────────────────────────────────────┤
│ Base Tables: dim_customer, fact_orders                          │
│                                                                  │
│ Dimensions:                                                      │
│   - customer_name, customer_tier, lifecycle_stage               │
│   - city, state, country                                        │
│   - order_date, first_order_date                                │
│                                                                  │
│ Measures:                                                        │
│   - customer_count, total_orders, total_revenue                 │
│   - avg_order_value, avg_lifetime_value                         │
│                                                                  │
│ Sample Questions:                                                │
│   - "How many customers by tier?"                               │
│   - "What is revenue by acquisition source?"                    │
└─────────────────────────────────────────────────────────────────┘
```

### 5.4 Design Checklist

- [ ] All entities identified
- [ ] Conformed models designed
- [ ] Dimensions designed with SCD type
- [ ] Facts designed with grain documented
- [ ] Semantic views designed
- [ ] Column mapping complete

---

## 6. Step 5: Macro Extraction

### 6.1 Purpose
Extract repeated logic into reusable macros.

### 6.2 Macro Identification

From analysis, list patterns to extract:

| Pattern | Frequency | Macro Name | Category |
|---------|-----------|------------|----------|
| Customer tier CASE | 5 | calculate_customer_tier | Tier Logic |
| Order tier CASE | 3 | calculate_order_tier | Tier Logic |
| Fiscal year calc | 4 | fiscal_year | Date Helpers |
| Margin calculation | 3 | margin_pct | Margins |

### 6.3 Macro Design

For each macro:

1. **Define signature**: Input parameters and defaults
2. **Document behavior**: What it returns
3. **Provide examples**: Usage patterns
4. **Make configurable**: Use vars for thresholds

### 6.4 Macro Checklist

- [ ] All repeated patterns identified
- [ ] Macros designed with proper signatures
- [ ] Documentation included
- [ ] Configuration via vars supported

---

## 7. Step 6: Generation

### 7.1 Purpose
Generate all output artifacts.

### 7.2 Generation Order

1. **Source Definitions** (schema.yml with sources)
2. **Macros** (all extracted patterns)
3. **Conformed Models** (cnf_*)
4. **Dimension Models** (dim_*)
5. **Fact Models** (fact_*)
6. **Schema Files** (documentation + tests)
7. **Semantic View Definitions** (YAML)
8. **DDL Scripts** (for reference)
9. **Documentation** (all required docs)

### 7.3 Generation Checklist

- [ ] Source definitions generated
- [ ] All macros generated
- [ ] All models generated
- [ ] All schema.yml files generated
- [ ] All semantic views generated
- [ ] All DDL scripts generated
- [ ] All documentation generated

---

## 8. Step 7: Validation

### 8.1 Purpose
Verify the generated output is correct and complete.

### 8.2 Validation Steps

#### 8.2.1 Compilation Check

```bash
dbt compile --select tag:{domain}
```

All models must compile without errors.

#### 8.2.2 Test Verification

```bash
dbt test --select tag:{domain}
```

All tests must pass.

#### 8.2.3 Information Equivalence

For each original model output, verify the new architecture produces equivalent information:

| Original | New | Check |
|----------|-----|-------|
| Column A from model X | Column A' from model Y | Values match |

#### 8.2.4 Documentation Completeness

Verify all documentation is generated:

- [ ] domain_overview.md
- [ ] data_dictionary.md
- [ ] lineage.md
- [ ] dbt_project_spec.md
- [ ] semantic_view_spec.md
- [ ] migration_report.md

### 8.3 Validation Checklist

- [ ] All models compile
- [ ] All tests pass
- [ ] Information equivalence verified
- [ ] All documentation complete
- [ ] Migration report generated

---

## 9. Decision Points

### 9.1 Entity Splitting Decision

**When to split an entity into dim + fact**:

| Condition | Action |
|-----------|--------|
| Entity has static attributes + transaction data | Split into dim + fact |
| Entity only has descriptive attributes | Create dim only |
| Entity only has transactional data | Create fact only |
| Entity has aggregated metrics | Consider whether metrics belong in dim or separate fact |

### 9.2 SCD Type Decision

| Scenario | SCD Type |
|----------|----------|
| Reference data that never changes | Type 0 |
| Corrections only, no history needed | Type 1 |
| Full history required for reporting | Type 2 |
| Only need current + previous | Type 3 |

### 9.3 Macro vs Inline Decision

| Scenario | Decision |
|----------|----------|
| Logic used in 1 model only | Keep inline |
| Logic used in 2+ models | Extract to macro |
| Logic involves business rules | Extract to macro |
| Logic is simple (1-2 lines) | Keep inline unless repeated |

---

## 10. Workflow State Tracking

Throughout the workflow, track progress:

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW STATUS                               │
├─────────────────────────────────────────────────────────────────┤
│ Step 1: Intake          [✅ COMPLETE]                            │
│ Step 2: Discovery       [✅ COMPLETE]                            │
│ Step 3: Analysis        [✅ COMPLETE]                            │
│ Step 4: Design          [🔄 IN PROGRESS]                         │
│ Step 5: Macros          [⏳ PENDING]                              │
│ Step 6: Generation      [⏳ PENDING]                              │
│ Step 7: Validation      [⏳ PENDING]                              │
├─────────────────────────────────────────────────────────────────┤
│ Current: Designing metrics layer for Customer entity            │
└─────────────────────────────────────────────────────────────────┘
```
