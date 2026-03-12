# DBT Best Practices & Dimensional Modeling Guide

This document provides comprehensive guidance for building high-quality DBT models following dimensional modeling principles, specifically tailored for the monolith-to-federated migration.

---

## 1. Dimensional Modeling Fundamentals

### 1.1 Star Schema Overview

A star schema consists of **fact tables** at the center, surrounded by **dimension tables**. This design optimizes analytical queries by minimizing joins and providing intuitive structures for business users.

```
                         ┌─────────────────┐
                         │    dim_date     │
                         └────────┬────────┘
                                  │
                                  │ date_key
                                  │
┌─────────────────┐      ┌────────┴────────┐      ┌─────────────────┐
│  dim_customer   │──────│   fact_orders   │──────│   dim_product   │
└─────────────────┘      └────────┬────────┘      └─────────────────┘
     customer_key                 │                    product_key
                                  │
                         ┌────────┴────────┐
                         │   dim_store     │
                         └─────────────────┘
                              store_key
```

### 1.2 Why Star Schema for This Migration

| Benefit | Description |
|---------|-------------|
| **Query Performance** | Fewer joins, optimized for Snowflake's columnar storage |
| **Business Intuitive** | Non-technical users can understand and query |
| **Flexible Analysis** | Drill-down, drill-across, slice-and-dice |
| **Semantic Layer Ready** | Maps directly to Snowflake Intelligence semantic views |
| **Maintainable** | Clear separation of concerns |

---

## 2. Fact Tables

### 2.1 Definition & Characteristics

Fact tables contain **measurable, quantitative data** about business processes. They are typically narrow (fewer columns) and deep (many rows).

| Property | Description | Example |
|----------|-------------|---------|
| **Grain** | The level of detail (what one row represents) | One row per order line item |
| **Surrogate Keys** | Foreign keys to dimension tables | `customer_key`, `product_key` |
| **Degenerate Dimensions** | Business identifiers with no dimension table | `order_id`, `invoice_number` |
| **Measures** | Numeric, additive values | `quantity`, `amount`, `cost` |
| **Timestamps** | Event timestamps | `order_at`, `shipped_at` |

### 2.2 Fact Table Types

| Type | Description | Grain | Example |
|------|-------------|-------|---------|
| **Transaction** | One row per business event | Atomic event | `fact_order_lines` - one row per item purchased |
| **Periodic Snapshot** | One row per period per entity | Time period | `fact_monthly_inventory` - monthly stock levels |
| **Accumulating Snapshot** | One row per lifecycle with multiple dates | Entity lifecycle | `fact_order_fulfillment` - tracks order stages |
| **Factless Fact** | Records events without measures | Event occurrence | `fact_promotion_coverage` - product-promotion mapping |

### 2.3 Fact Table Template

```sql
-- models/metrics/facts/fact_orders.sql
{{
    config(
        materialized='incremental',
        unique_key='order_line_key',
        incremental_strategy='merge',
        cluster_by=['order_date', 'customer_key']
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('cnf_orders') }}
),

customers AS (
    SELECT customer_key, customer_id
    FROM {{ ref('dim_customer') }}
    WHERE is_current = TRUE
),

products AS (
    SELECT product_key, product_id
    FROM {{ ref('dim_product') }}
    WHERE is_current = TRUE
),

dates AS (
    SELECT date_key, date_day
    FROM {{ ref('dim_date') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['o.order_id', 'o.line_number']) }} AS order_line_key,
    
    c.customer_key,
    p.product_key,
    d.date_key,
    
    o.order_id,
    o.line_number,
    o.order_number,
    
    o.quantity,
    o.unit_price,
    o.quantity * o.unit_price AS line_amount,
    o.discount_amount,
    o.tax_amount,
    o.shipping_amount,
    {{ gross_margin('o.unit_price', 'o.unit_cost') }} AS unit_margin,
    {{ margin_pct('o.unit_price', 'o.unit_cost') }} AS margin_pct,
    
    o.order_at,
    o.shipped_at,
    o.delivered_at,
    DATE(o.order_at) AS order_date

FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN dates d ON DATE(o.order_at) = d.date_day

{% if is_incremental() %}
WHERE o.order_at > (SELECT MAX(order_at) FROM {{ this }})
{% endif %}
```

### 2.4 Fact Table Rules

| Rule | Requirement | Rationale |
|------|-------------|-----------|
| **Define Grain First** | Document grain before writing SQL | Prevents confusion, ensures consistency |
| **Foreign Keys Only** | Reference dimensions via surrogate keys | Enables dimension updates without fact changes |
| **Additive Measures** | Ensure measures can be summed | Enables roll-up aggregations |
| **No Dimension Attributes** | Never embed dimension attributes | Avoid update anomalies |
| **Degenerate Dimensions OK** | Keep `order_id`, `invoice_number` | No need for single-column dimension |
| **Consistent Timestamps** | Include event timestamps | Enables time-based analysis |

---

## 3. Dimension Tables

### 3.1 Definition & Characteristics

Dimension tables contain **descriptive attributes** that provide context for facts. They are typically wide (many columns) and shallow (fewer rows).

| Property | Description | Example |
|----------|-------------|---------|
| **Surrogate Key** | System-generated unique identifier | `customer_key` (hash or sequence) |
| **Natural Key** | Business identifier from source | `customer_id` |
| **Attributes** | Descriptive text, categories | `customer_name`, `segment` |
| **Hierarchies** | Organizational levels | `city → state → country → region` |
| **SCD Metadata** | Validity tracking | `valid_from`, `valid_to`, `is_current` |

### 3.2 Slowly Changing Dimension (SCD) Types

| Type | Description | Use Case | Implementation |
|------|-------------|----------|----------------|
| **Type 0** | No changes tracked | Static reference data | Overwrite, no history |
| **Type 1** | Overwrite old value | Corrections, non-historical | UPDATE in place |
| **Type 2** | Add new row with validity dates | Full history required | INSERT new row, expire old |
| **Type 3** | Add column for previous value | Limited history | `current_value`, `previous_value` |

### 3.3 Dimension Table Template

```sql
-- models/metrics/dimensions/dim_customer.sql
{{
    config(
        materialized='table',
        unique_key='customer_key'
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('cnf_customers') }}
),

customer_metrics AS (
    SELECT
        customer_id,
        SUM(order_amount) AS lifetime_value,
        COUNT(DISTINCT order_id) AS total_orders,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date
    FROM {{ ref('cnf_orders') }}
    GROUP BY customer_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_id', 'c.valid_from']) }} AS customer_key,
    
    c.customer_id,
    
    c.first_name,
    c.last_name,
    c.first_name || ' ' || c.last_name AS full_name,
    c.email,
    c.phone,
    
    c.city,
    c.state,
    c.country,
    c.postal_code,
    
    c.customer_segment,
    c.acquisition_channel,
    c.acquisition_source,
    
    {{ calculate_customer_tier('COALESCE(cm.lifetime_value, 0)') }} AS customer_tier,
    
    COALESCE(cm.lifetime_value, 0) AS lifetime_value,
    COALESCE(cm.total_orders, 0) AS total_orders,
    cm.first_order_date,
    cm.last_order_date,
    
    CASE
        WHEN cm.last_order_date >= DATEADD(day, -365, CURRENT_DATE()) THEN TRUE
        ELSE FALSE
    END AS is_active,
    
    c.is_verified,
    c.has_subscription,
    
    c.valid_from,
    c.valid_to,
    c.is_current,
    
    c.created_at,
    c.updated_at

FROM customers c
LEFT JOIN customer_metrics cm ON c.customer_id = cm.customer_id
```

### 3.4 Dimension Table Rules

| Rule | Requirement | Rationale |
|------|-------------|-----------|
| **Surrogate Keys** | Generate stable keys independent of source | Handles source key changes |
| **Natural Keys Preserved** | Keep business identifiers | Traceability to source |
| **Descriptive Attributes** | Include all filtering/grouping attributes | Enables analysis |
| **Hierarchies Flattened** | Denormalize hierarchies | Simplifies queries |
| **SCD Strategy Defined** | Document and implement appropriate type | Preserves history when needed |

### 3.5 Common Conformed Dimensions

| Dimension | Description | Shared Across |
|-----------|-------------|---------------|
| `dim_date` | Calendar dimension | All fact tables with dates |
| `dim_customer` | Customer master | Orders, Sessions, Support, Marketing |
| `dim_product` | Product catalog | Orders, Inventory, Returns |
| `dim_employee` | Employee/user data | Sales, Support, Operations |
| `dim_geography` | Location hierarchy | Orders, Customers, Stores |

### 3.6 Date Dimension Template

```sql
-- models/metrics/dimensions/dim_date.sql
{{
    config(
        materialized='table'
    )
}}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

dates AS (
    SELECT
        CAST(date_day AS DATE) AS date_day
    FROM date_spine
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_key,
    
    date_day,
    
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    WEEK(date_day) AS week_of_year,
    DAY(date_day) AS day_of_month,
    DAYOFWEEK(date_day) AS day_of_week,
    
    TO_CHAR(date_day, 'YYYY-MM') AS year_month,
    TO_CHAR(date_day, 'YYYY') || '-Q' || QUARTER(date_day) AS year_quarter,
    
    MONTHNAME(date_day) AS month_name,
    LEFT(MONTHNAME(date_day), 3) AS month_name_short,
    DAYNAME(date_day) AS day_name,
    LEFT(DAYNAME(date_day), 3) AS day_name_short,
    
    {{ fiscal_year('date_day') }} AS fiscal_year,
    {{ fiscal_quarter('date_day') }} AS fiscal_quarter,
    {{ fiscal_month('date_day') }} AS fiscal_month,
    
    CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE WHEN DAYOFWEEK(date_day) BETWEEN 1 AND 5 THEN TRUE ELSE FALSE END AS is_weekday,
    
    date_day = CURRENT_DATE() AS is_today,
    date_day < CURRENT_DATE() AS is_past,
    date_day > CURRENT_DATE() AS is_future

FROM dates
```

---

## 4. Three-Layer Architecture Best Practices

### 4.1 Source Layer

**Purpose**: Define and reference raw source data

**Rules**:
- Define ALL sources in `schema.yml`
- Use `{{ source() }}` macro EXCLUSIVELY
- Add freshness checks where applicable
- Document source tables and columns

```yaml
# models/staging/schema.yml
version: 2

sources:
  - name: raw_ecommerce
    description: Raw e-commerce operational data
    database: "{{ var('source_database', 'RAW_DB') }}"
    schema: "{{ var('source_schema', 'ECOMMERCE') }}"
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    loaded_at_field: _etl_loaded_at
    tables:
      - name: customers
        description: Raw customer master data from CRM
        columns:
          - name: customer_id
            description: Unique customer identifier (natural key)
            tests:
              - unique
              - not_null
      - name: orders
        description: Raw order transactions from e-commerce platform
      - name: products
        description: Raw product catalog from PIM
```

### 4.2 Conformed Layer (`cnf_`)

**Purpose**: Cleanse, standardize, and create reusable event-level data

**Rules**:

| Rule | Description |
|------|-------------|
| **One Model Per Entity** | Single `cnf_customers`, not multiple variations |
| **Event-Level Grain** | Preserve lowest level of detail |
| **Standardized Naming** | Consistent column names across all models |
| **No Aggregations** | Aggregations belong in metrics layer |
| **Business Key Resolution** | Handle duplicates, merge records here |
| **Source References Only** | Use `{{ source() }}` not direct table references |

**Template**:

```sql
-- models/conformed/cnf_customers.sql
{{
    config(
        materialized='table',
        unique_key='customer_id'
    )
}}

WITH source AS (
    SELECT * FROM {{ source('raw_ecommerce', 'customers') }}
),

cleaned AS (
    SELECT
        customer_id,
        
        TRIM(LOWER(email)) AS email,
        INITCAP(TRIM(first_name)) AS first_name,
        INITCAP(TRIM(last_name)) AS last_name,
        
        REGEXP_REPLACE(phone, '[^0-9]', '') AS phone,
        
        INITCAP(TRIM(city)) AS city,
        UPPER(TRIM(state_code)) AS state,
        UPPER(TRIM(country_code)) AS country,
        TRIM(postal_code) AS postal_code,
        
        customer_segment,
        acquisition_channel,
        
        created_at,
        updated_at,
        
        CURRENT_TIMESTAMP() AS valid_from,
        CAST('9999-12-31' AS TIMESTAMP) AS valid_to,
        TRUE AS is_current,
        
        _etl_loaded_at AS loaded_at

    FROM source
    WHERE customer_id IS NOT NULL
      AND email IS NOT NULL
)

SELECT * FROM cleaned
```

### 4.3 Metrics Layer (`dim_`, `fact_`)

**Purpose**: Provide dimensional models optimized for analytics

**Dimension Rules**:

| Rule | Description |
|------|-------------|
| **Surrogate Keys** | Generate stable keys independent of source |
| **Natural Keys Preserved** | Keep business identifiers for traceability |
| **Descriptive Attributes** | Include all attributes needed for filtering/grouping |
| **Hierarchies Flattened** | Denormalize hierarchies into dimension |
| **SCD Handling** | Implement appropriate SCD type |

**Fact Rules**:

| Rule | Description |
|------|-------------|
| **Defined Grain** | Document and enforce grain in model header |
| **Foreign Keys Only** | Reference dimensions via surrogate keys |
| **Additive Measures** | Ensure measures can be summed meaningfully |
| **No Dimension Attributes** | Never embed dimension attributes in facts |
| **Degenerate Dimensions OK** | Order numbers, transaction IDs can stay |

### 4.4 Semantic Layer

**Purpose**: Provide governed, business-friendly interface for end users

**Rules**:

| Rule | Description |
|------|-------------|
| **Reads from Metrics Only** | Never reference conformed or source directly |
| **Business Terminology** | Use business names, not technical names |
| **Pre-defined Metrics** | Include calculated measures with clear definitions |
| **Governed Access** | Apply security policies where needed |
| **Snowflake Semantic Views** | Use Snowflake-native semantic view format |

---

## 5. Anti-Patterns to Avoid

### 5.1 Structural Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **One Big Table (OBT)** | Single denormalized table with everything | Proper star schema with facts + dims |
| **Metrics in Dimensions** | Aggregated values stored in dim tables | Keep measures in fact tables only |
| **Dimension Attributes in Facts** | Customer name, product category in fact | Use foreign keys, join to dimension |
| **Multiple Staging Models** | 3 staging models for same source table | Single conformed model per entity |
| **Skipping Layers** | Reports reading directly from raw tables | Enforce layer dependencies |
| **Circular Dependencies** | Model A refs B, B refs A | Redesign to eliminate cycles |

### 5.2 Code Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Hardcoded Values** | `WHERE date > '2024-01-01'` | Use variables or macros |
| **Repeated Logic** | Same CASE statement in 10 models | Extract to macro |
| **Inconsistent Naming** | `cust_id`, `customer_id`, `custID` | Enforce naming convention |
| **Direct Source References** | `FROM RAW_DB.SCHEMA.TABLE` | Use `{{ source() }}` |
| **Missing Tests** | No tests on primary keys | Test all PKs and FKs |
| **Undocumented Models** | No descriptions in schema.yml | Document all models and columns |

### 5.3 Anti-Pattern Examples

#### ❌ BAD: Metrics in Dimension

```sql
SELECT
    customer_id,
    customer_name,
    email,
    total_orders,        -- WRONG: This is a METRIC
    lifetime_revenue,    -- WRONG: This is a METRIC
    avg_order_value      -- WRONG: This is a METRIC
FROM ...
```

#### ✅ GOOD: Clean Dimension

```sql
SELECT
    customer_key,
    customer_id,
    customer_name,
    email,
    customer_segment,    -- Descriptive attribute
    acquisition_channel, -- Descriptive attribute
    is_active            -- Flag attribute
FROM ...
```

#### ❌ BAD: Dimension Attributes in Fact

```sql
SELECT
    order_id,
    customer_id,
    customer_name,       -- WRONG: dimension attribute
    customer_email,      -- WRONG: dimension attribute
    customer_tier,       -- WRONG: dimension attribute
    product_id,
    product_name,        -- WRONG: dimension attribute
    product_category,    -- WRONG: dimension attribute
    order_amount
FROM ...
```

#### ✅ GOOD: Clean Fact

```sql
SELECT
    order_key,
    customer_key,        -- FK to dim_customer
    product_key,         -- FK to dim_product
    date_key,            -- FK to dim_date
    order_id,            -- Degenerate dimension
    quantity,            -- Measure
    unit_price,          -- Measure
    order_amount,        -- Measure
    discount_amount,     -- Measure
    tax_amount           -- Measure
FROM ...
```

---

## 6. Macro Best Practices

### 6.1 When to Create a Macro

Create a macro when:
- Logic is used in **2+ models**
- Logic involves **business rules** that may change
- Logic is **complex** and benefits from encapsulation
- Logic needs to be **centrally maintained**

### 6.2 Macro Structure

```sql
-- macros/tier_logic/calculate_customer_tier.sql

{% macro calculate_customer_tier(lifetime_value_column, tier_config=none) %}
{#
    Calculate customer tier based on lifetime value.
    
    Args:
        lifetime_value_column: Column or expression containing customer LTV
        tier_config: Optional dict with custom thresholds
            Default: {platinum: 10000, gold: 5000, silver: 1000}
        
    Returns:
        CASE statement for tier calculation
        
    Example:
        {{ calculate_customer_tier('lifetime_value') }}
        {{ calculate_customer_tier('total_revenue', {'platinum': 50000, 'gold': 25000, 'silver': 5000}) }}
#}

{% set config = tier_config or var('customer_tier_thresholds', {
    'platinum': 10000,
    'gold': 5000,
    'silver': 1000
}) %}

CASE
    WHEN {{ lifetime_value_column }} >= {{ config.platinum }} THEN 'PLATINUM'
    WHEN {{ lifetime_value_column }} >= {{ config.gold }} THEN 'GOLD'
    WHEN {{ lifetime_value_column }} >= {{ config.silver }} THEN 'SILVER'
    ELSE 'BRONZE'
END
{% endmacro %}
```

### 6.3 Macro Documentation

All macros MUST include:
- Description of purpose
- Args documentation with types and defaults
- Returns documentation
- At least one usage example

### 6.4 Required Macros for Migration

| Category | Macro | Purpose |
|----------|-------|---------|
| **Tier Logic** | `calculate_customer_tier` | Customer value tiers |
| **Tier Logic** | `calculate_order_tier` | Order value tiers |
| **Tier Logic** | `calculate_product_tier` | Product performance tiers |
| **Date Helpers** | `fiscal_year` | Calculate fiscal year |
| **Date Helpers** | `fiscal_quarter` | Calculate fiscal quarter |
| **Date Helpers** | `fiscal_month` | Calculate fiscal month |
| **Margins** | `gross_margin` | Revenue minus cost |
| **Margins** | `margin_pct` | Margin as percentage |

---

## 7. Testing Standards

### 7.1 Minimum Required Tests by Model Type

#### Dimension Tables

```yaml
models:
  - name: dim_customer
    description: Customer dimension with SCD Type 2
    columns:
      - name: customer_key
        description: Surrogate primary key
        tests:
          - unique
          - not_null
      - name: customer_id
        description: Natural business key
        tests:
          - not_null
      - name: email
        tests:
          - not_null
      - name: customer_tier
        tests:
          - accepted_values:
              values: ['PLATINUM', 'GOLD', 'SILVER', 'BRONZE']
      - name: is_current
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

#### Fact Tables

```yaml
models:
  - name: fact_orders
    description: Order line item fact table
    columns:
      - name: order_line_key
        tests:
          - unique
          - not_null
      - name: customer_key
        tests:
          - not_null
          - relationships:
              to: ref('dim_customer')
              field: customer_key
      - name: product_key
        tests:
          - not_null
          - relationships:
              to: ref('dim_product')
              field: product_key
      - name: date_key
        tests:
          - not_null
          - relationships:
              to: ref('dim_date')
              field: date_key
      - name: quantity
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 1"
      - name: order_amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

### 7.2 Test Coverage Matrix

| Model Type | Primary Key | Natural Key | Foreign Keys | Measures | Flags |
|------------|-------------|-------------|--------------|----------|-------|
| **Dimension** | unique + not_null | not_null | N/A | N/A | accepted_values |
| **Fact** | unique + not_null | not_null | relationships + not_null | >= 0 | N/A |
| **Conformed** | unique + not_null | not_null | N/A | N/A | N/A |

### 7.3 Custom Business Rule Tests

```sql
-- tests/custom/assert_order_amounts_balance.sql
SELECT
    order_id,
    SUM(line_amount) AS line_total,
    order_amount,
    ABS(SUM(line_amount) - order_amount) AS difference
FROM {{ ref('fact_orders') }}
GROUP BY order_id, order_amount
HAVING ABS(SUM(line_amount) - order_amount) > 0.01
```

---

## 8. Performance Best Practices

### 8.1 Incremental Models

Use for large fact tables:

```sql
{{
    config(
        materialized='incremental',
        unique_key='order_line_key',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

SELECT ...
FROM {{ ref('cnf_orders') }}

{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

### 8.2 Clustering

Define clustering keys for large tables:

```sql
{{
    config(
        materialized='table',
        cluster_by=['date_key', 'customer_key']
    )
}}
```

**Clustering Guidelines**:
- Choose columns used in WHERE clauses and JOINs
- Prefer low-cardinality columns first
- Limit to 3-4 clustering columns
- Date columns are excellent candidates

### 8.3 Model Dependencies

- Keep dependency chains shallow (max 4-5 levels)
- Avoid circular dependencies
- Use `ref()` consistently to track lineage
- Consider model grouping for parallel execution

---

## 9. Documentation Standards

### 9.1 Model Documentation

```yaml
models:
  - name: fact_orders
    description: |
      ## Order Line Item Fact Table
      
      **Grain**: One row per order line item
      
      **Primary Key**: `order_line_key`
      
      **Update Frequency**: Daily (incremental)
      
      **Business Owner**: Product Experience Domain
      
      ### Usage Notes
      - Join to `dim_customer` for customer attributes
      - Join to `dim_product` for product attributes
      - Use `date_key` to join to `dim_date` for time analysis
      
      ### Key Metrics
      - `line_amount`: Unit price × quantity
      - `margin_pct`: Profit margin percentage
      
      ### Known Issues
      - Historical orders before 2020 may have missing `product_key`
```

### 9.2 Column Documentation

```yaml
columns:
  - name: customer_key
    description: |
      Surrogate key for customer dimension.
      Use this key to join to `dim_customer`.
      **Do not** use `customer_id` for joins.
    
  - name: order_amount
    description: |
      Total amount for this order line item.
      **Calculation**: `quantity × unit_price - discount_amount`
      **Currency**: USD
      **Additive**: Yes - can be summed across any dimension
```

---

## 10. Cross-Domain Data Sharing

### 10.1 Shared vs Domain-Owned Models

| Shared (Central) | Domain-Owned |
|------------------|--------------|
| `cnf_customers` | `fact_pex_sessions` |
| `cnf_products` | `fact_mon_transactions` |
| `cnf_orders` | `fact_mkt_campaigns` |
| `dim_date` | `dim_pex_feature` |
| `dim_geography` | `dim_mon_subscription_plan` |

### 10.2 Cross-Project References

```sql
SELECT *
FROM {{ ref('shared_project', 'cnf_customers') }}
```

### 10.3 Package Dependencies

```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.0.0", "<2.0.0"]
  - package: calogica/dbt_expectations
    version: [">=0.10.0", "<0.11.0"]
  - git: "https://github.com/org/shared_macros.git"
    revision: main
```

---

## 11. Pre-Merge Checklist

Before merging any model:

### Structure
- [ ] Model follows naming convention (`cnf_`, `dim_`, `fact_`, `sv_`)
- [ ] All sources use `{{ source() }}` macro
- [ ] All dependencies use `{{ ref() }}` macro
- [ ] No dimension attributes in fact tables
- [ ] No metrics in dimension tables
- [ ] Grain is documented for fact tables

### Testing
- [ ] Primary key has `unique` and `not_null` tests
- [ ] Foreign keys have `relationships` tests
- [ ] Business rule tests added where applicable
- [ ] All tests pass locally

### Code Quality
- [ ] Repeated logic uses macros
- [ ] No hardcoded dates or values
- [ ] Incremental strategy defined for large facts
- [ ] Clustering defined for large tables

### Documentation
- [ ] Model has description in schema.yml
- [ ] Key columns have descriptions
- [ ] Usage notes included
- [ ] Known issues documented

---

## 12. Quick Reference

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Conformed Model | `cnf_{entity}` | `cnf_customers` |
| Dimension | `dim_{entity}` | `dim_customer` |
| Fact | `fact_{process}` | `fact_orders` |
| Semantic View | `sv_{domain}_{subject}` | `sv_pex_analytics` |
| Surrogate Key | `{entity}_key` | `customer_key` |
| Natural Key | `{entity}_id` | `customer_id` |
| Timestamp | `{event}_at` | `created_at` |
| Date | `{event}_date` | `order_date` |
| Boolean | `is_{state}` | `is_active` |
| Amount | `{thing}_amount` | `order_amount` |
| Count | `{thing}_count` | `order_count` |
| Percentage | `{thing}_pct` | `margin_pct` |

### Layer Dependencies

```
source() → cnf_ → dim_/fact_ → semantic views
```

### Config Defaults

| Model Type | Materialized | Strategy |
|------------|--------------|----------|
| Conformed | table | - |
| Dimension | table | - |
| Fact (small) | table | - |
| Fact (large) | incremental | merge |
| Semantic | view | - |
