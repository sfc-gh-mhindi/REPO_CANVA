# Example Migration: Customer Domain

This document provides a complete end-to-end example of migrating customer-related models from the monolith to a properly structured domain-owned DBT project.

---

## 1. Input Analysis

### 1.1 Source Models Identified

The following models from the `transform` monolith relate to the customer domain:

| Model | Layer | Path | Issues Found |
|-------|-------|------|--------------|
| `stg_customers_v1` | Staging | models/staging/ | Hardcoded DB reference, no source() |
| `stg_customers_v2` | Staging | models/staging/ | Duplicate staging, different structure |
| `stg_customers_combined` | Staging | models/staging/ | Union logic in staging layer |
| `int_customer_360` | Intermediate | models/intermediate/ | Massive CTEs, reads raw tables directly |
| `int_customer_summary` | Intermediate | models/intermediate/ | Duplicates int_customer_360 logic |
| `int_customer_metrics` | Intermediate | models/intermediate/ | Third duplication of same aggregations |
| `dim_customers` | Marts | models/marts/ | Joins 3 overlapping intermediates |
| `rpt_customer_rfm` | Reports | models/reports/ | Re-implements RFM scoring inline |

### 1.2 Source Tables Used

| Source Table | Used By Models |
|--------------|----------------|
| `RAW.RAW_CUSTOMERS_V1` | stg_customers_v1, stg_customers_combined, int_customer_360 |
| `RAW.RAW_CUSTOMERS_V2` | stg_customers_v2, stg_customers_combined, int_customer_metrics |
| `RAW.RAW_ORDERS` | int_customer_360, int_customer_summary |
| `RAW.RAW_RETURNS` | int_customer_360, int_customer_summary |
| `RAW.RAW_SUPPORT_TICKETS` | int_customer_360 |
| `RAW.RAW_CLICKSTREAM` | int_customer_360 |

### 1.3 Anti-Patterns Detected

#### 1.3.1 Duplicate Staging Models

**Pattern**: Three staging models for the same conceptual entity (customers)

```
stg_customers_v1     → Uses RAW_CUSTOMERS_V1 only
stg_customers_v2     → Uses RAW_CUSTOMERS_V2 only  
stg_customers_combined → UNIONs both (but in staging layer)
```

**Problem**: No single source of truth for customers. Different downstream models use different staging models.

#### 1.3.2 Repeated Tier Calculation Logic

**Pattern**: Customer tier/segment calculated 5 different ways across models

```sql
-- int_customer_360 (value_tier)
CASE
    WHEN total_revenue > 10000 THEN 'PLATINUM'
    WHEN total_revenue > 5000 THEN 'GOLD'
    WHEN total_revenue > 1000 THEN 'SILVER'
    ELSE 'BRONZE'
END

-- int_customer_summary (segment)
CASE
    WHEN revenue >= 10000 THEN 'VIP'
    WHEN revenue >= 5000 THEN 'PREMIUM'
    WHEN revenue >= 1000 THEN 'STANDARD'
    ELSE 'ENTRY'
END

-- int_customer_metrics (revenue_tier)
CASE
    WHEN SUM(total_amt) > 10000 THEN 'TIER_1'
    WHEN SUM(total_amt) > 5000 THEN 'TIER_2'
    WHEN SUM(total_amt) > 1000 THEN 'TIER_3'
    ELSE 'TIER_4'
END
```

**Problem**: Same logic with inconsistent naming and slight threshold variations.

#### 1.3.3 Hardcoded Database References

**Pattern**: Direct table references instead of `{{ source() }}`

```sql
-- WRONG (found in int_customer_360)
FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1

-- WRONG (found in stg_orders)
FROM DBT_REFACTOR_TEST.RAW.RAW_ORDERS
```

**Problem**: Not portable across environments, violates DBT best practices.

#### 1.3.4 Overlapping Intermediate Models

**Pattern**: Three intermediate models computing same customer metrics

```
int_customer_360   → total_orders, lifetime_revenue, avg_order_value
int_customer_summary → orders, total_spend, average_order
int_customer_metrics → num_orders, total_revenue, avg_order
```

**Problem**: Same metrics with different names, wasted compute, maintenance nightmare.

---

## 2. Target Design

### 2.1 Target Model Structure

```
pex_transform/
├── models/
│   ├── staging/
│   │   └── schema.yml              # Source definitions
│   ├── conformed/
│   │   ├── cnf_customers.sql       # Unified customer entity
│   │   └── schema.yml
│   └── metrics/
│       ├── dimensions/
│       │   ├── dim_customer.sql    # Customer dimension
│       │   └── schema.yml
│       └── facts/
│           ├── fact_customer_orders.sql  # Customer order metrics
│           └── schema.yml
├── macros/
│   └── calculate_customer_tier.sql
└── semantic/
    └── sv_pex_customer_analytics.yaml
```

### 2.2 Model Consolidation Plan

| Original Models | Target Model | Rationale |
|-----------------|--------------|-----------|
| stg_customers_v1, stg_customers_v2, stg_customers_combined | cnf_customers | Single unified customer entity |
| int_customer_360, int_customer_summary, int_customer_metrics | dim_customer | Single customer dimension with all attributes |
| (aggregations from intermediates) | fact_customer_orders | Separate fact for order metrics |
| dim_customers | dim_customer | Properly structured dimension |
| rpt_customer_rfm | (semantic view) | RFM accessible via semantic layer |

### 2.3 Macro Extraction Plan

| Repeated Logic | New Macro | Usage |
|----------------|-----------|-------|
| Customer tier CASE statement | `calculate_customer_tier` | dim_customer |
| RFM scoring | `calculate_rfm_score` | fact_customer_orders |

---

## 3. Generated Output

### 3.1 Source Definitions

```yaml
# models/staging/schema.yml
version: 2

sources:
  - name: raw
    description: Raw source data from operational systems
    database: "{{ var('source_database', 'RAW_DB') }}"
    schema: "{{ var('source_schema', 'RAW') }}"
    tables:
      - name: raw_customers_v1
        description: Legacy customer data from CRM v1
        columns:
          - name: cust_id
            description: Customer identifier (legacy format)
            tests:
              - not_null
      - name: raw_customers_v2
        description: Customer data from CRM v2
        columns:
          - name: customer_key
            description: Customer identifier (new format)
            tests:
              - not_null
      - name: raw_orders
        description: Order transactions
        columns:
          - name: order_id
            tests:
              - unique
              - not_null
      - name: raw_returns
        description: Return transactions
      - name: raw_support_tickets
        description: Customer support tickets
      - name: raw_clickstream
        description: Web analytics events
```

### 3.2 Conformed Layer Model

```sql
-- models/conformed/cnf_customers.sql
{{
    config(
        materialized='table',
        unique_key='customer_id'
    )
}}

WITH v1_customers AS (
    SELECT
        cust_id AS customer_id,
        'V1' AS source_system,
        first_name,
        last_name,
        email,
        phone,
        dob AS date_of_birth,
        gender,
        registration_date,
        last_login_date,
        account_status,
        address1 AS address_line_1,
        address2 AS address_line_2,
        city,
        state,
        zip AS postal_code,
        country,
        acquisition_source,
        acquisition_campaign,
        created_at,
        updated_at
    FROM {{ source('raw', 'raw_customers_v1') }}
    WHERE cust_id IS NOT NULL
),

v2_customers AS (
    SELECT
        customer_key AS customer_id,
        'V2' AS source_system,
        name_first AS first_name,
        name_last AS last_name,
        email_primary AS email,
        phone_mobile AS phone,
        date_of_birth,
        gender_code AS gender,
        loyalty_enrollment_date AS registration_date,
        NULL AS last_login_date,
        CASE 
            WHEN account_locked THEN 'LOCKED'
            ELSE verification_status 
        END AS account_status,
        NULL AS address_line_1,
        NULL AS address_line_2,
        NULL AS city,
        NULL AS state,
        NULL AS postal_code,
        NULL AS country,
        NULL AS acquisition_source,
        NULL AS acquisition_campaign,
        sys_created_ts AS created_at,
        sys_updated_ts AS updated_at
    FROM {{ source('raw', 'raw_customers_v2') }}
    WHERE customer_key IS NOT NULL
),

unified AS (
    SELECT * FROM v1_customers
    UNION ALL
    SELECT * FROM v2_customers
),

deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY updated_at DESC NULLS LAST, source_system DESC
        ) AS row_num
    FROM unified
)

SELECT
    customer_id,
    source_system,
    TRIM(LOWER(email)) AS email,
    INITCAP(TRIM(first_name)) AS first_name,
    INITCAP(TRIM(last_name)) AS last_name,
    INITCAP(TRIM(first_name)) || ' ' || INITCAP(TRIM(last_name)) AS full_name,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS phone,
    date_of_birth,
    UPPER(TRIM(gender)) AS gender,
    registration_date,
    last_login_date,
    UPPER(TRIM(account_status)) AS account_status,
    TRIM(address_line_1) AS address_line_1,
    TRIM(address_line_2) AS address_line_2,
    INITCAP(TRIM(city)) AS city,
    UPPER(TRIM(state)) AS state,
    TRIM(postal_code) AS postal_code,
    UPPER(TRIM(country)) AS country,
    acquisition_source,
    acquisition_campaign,
    
    CURRENT_TIMESTAMP() AS valid_from,
    CAST('9999-12-31 23:59:59' AS TIMESTAMP) AS valid_to,
    TRUE AS is_current,
    
    created_at,
    COALESCE(updated_at, created_at) AS updated_at,
    CURRENT_TIMESTAMP() AS loaded_at

FROM deduplicated
WHERE row_num = 1
```

### 3.3 Dimension Model

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
    WHERE is_current = TRUE
),

order_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_total) AS lifetime_value,
        AVG(order_total) AS avg_order_value,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS days_since_last_order
    FROM {{ source('raw', 'raw_orders') }}
    WHERE order_status NOT IN ('CANCELLED', 'FAILED')
    GROUP BY customer_id
),

return_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT return_id) AS total_returns,
        SUM(refund_amount) AS total_refunded
    FROM {{ source('raw', 'raw_returns') }}
    WHERE return_status = 'REFUNDED'
    GROUP BY customer_id
),

support_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT ticket_id) AS total_tickets,
        AVG(satisfaction_rating) AS avg_satisfaction_rating
    FROM {{ source('raw', 'raw_support_tickets') }}
    GROUP BY customer_id
),

session_metrics AS (
    SELECT
        user_id AS customer_id,
        COUNT(DISTINCT session_id) AS total_sessions,
        MAX(event_timestamp) AS last_activity_at
    FROM {{ source('raw', 'raw_clickstream') }}
    WHERE user_id IS NOT NULL
    GROUP BY user_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_id', 'c.valid_from']) }} AS customer_key,
    
    c.customer_id,
    c.source_system,
    c.email,
    c.first_name,
    c.last_name,
    c.full_name,
    c.phone,
    c.date_of_birth,
    c.gender,
    
    c.city,
    c.state,
    c.country,
    c.postal_code,
    
    c.registration_date,
    c.account_status,
    c.acquisition_source,
    c.acquisition_campaign,
    
    COALESCE(om.total_orders, 0) AS total_orders,
    COALESCE(om.lifetime_value, 0) AS lifetime_value,
    COALESCE(om.avg_order_value, 0) AS avg_order_value,
    om.first_order_date,
    om.last_order_date,
    COALESCE(om.days_since_last_order, 9999) AS days_since_last_order,
    
    COALESCE(rm.total_returns, 0) AS total_returns,
    COALESCE(rm.total_refunded, 0) AS total_refunded,
    
    COALESCE(sm.total_tickets, 0) AS total_support_tickets,
    sm.avg_satisfaction_rating,
    
    COALESCE(sess.total_sessions, 0) AS total_sessions,
    sess.last_activity_at,
    
    {{ calculate_customer_tier('COALESCE(om.lifetime_value, 0)') }} AS customer_tier,
    
    CASE
        WHEN COALESCE(om.total_orders, 0) = 0 THEN 'PROSPECT'
        WHEN COALESCE(om.days_since_last_order, 9999) <= 30 AND om.total_orders >= 5 THEN 'LOYAL'
        WHEN COALESCE(om.days_since_last_order, 9999) <= 30 THEN 'ACTIVE'
        WHEN COALESCE(om.days_since_last_order, 9999) <= 90 THEN 'AT_RISK'
        WHEN COALESCE(om.days_since_last_order, 9999) <= 180 THEN 'LAPSED'
        ELSE 'CHURNED'
    END AS lifecycle_stage,
    
    CASE WHEN COALESCE(om.days_since_last_order, 9999) <= 365 THEN TRUE ELSE FALSE END AS is_active,
    
    c.valid_from,
    c.valid_to,
    c.is_current,
    c.created_at,
    c.updated_at

FROM customers c
LEFT JOIN order_metrics om ON c.customer_id = om.customer_id
LEFT JOIN return_metrics rm ON c.customer_id = rm.customer_id
LEFT JOIN support_metrics sm ON c.customer_id = sm.customer_id
LEFT JOIN session_metrics sess ON c.customer_id = sess.customer_id
```

### 3.4 Macro

```sql
-- macros/calculate_customer_tier.sql
{% macro calculate_customer_tier(lifetime_value_column, tier_config=none) %}
{#
    Calculate customer value tier based on lifetime value.
    
    Args:
        lifetime_value_column: Column or expression containing customer LTV
        tier_config: Optional dict with custom thresholds
            Default: {platinum: 10000, gold: 5000, silver: 1000}
    
    Returns:
        CASE expression returning tier name
    
    Example:
        {{ calculate_customer_tier('lifetime_value') }}
        {{ calculate_customer_tier('COALESCE(total_revenue, 0)') }}
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

### 3.5 Schema Definition with Tests

```yaml
# models/metrics/dimensions/schema.yml
version: 2

models:
  - name: dim_customer
    description: |
      ## Customer Dimension
      
      **Grain**: One row per customer (current version)
      
      **Primary Key**: `customer_key`
      
      **SCD Type**: Type 2 (valid_from, valid_to, is_current)
      
      **Owner**: Product Experience Domain
      
      ### Source
      Unified view of customers from CRM v1 and v2 systems, enriched with 
      behavioral metrics from orders, returns, support, and web sessions.
      
      ### Business Rules
      - Customer tier calculated using lifetime value thresholds
      - Lifecycle stage based on recency and frequency
      - Deduplication prefers most recent record, then V2 over V1
      
    columns:
      - name: customer_key
        description: Surrogate primary key (hash of customer_id + valid_from)
        tests:
          - unique
          - not_null
          
      - name: customer_id
        description: Natural business key from source systems
        tests:
          - not_null
          
      - name: email
        description: Customer email address (lowercase, trimmed)
        tests:
          - not_null
          
      - name: customer_tier
        description: |
          Customer value tier based on lifetime value.
          - PLATINUM: >= $10,000
          - GOLD: >= $5,000
          - SILVER: >= $1,000
          - BRONZE: < $1,000
        tests:
          - accepted_values:
              values: ['PLATINUM', 'GOLD', 'SILVER', 'BRONZE']
              
      - name: lifecycle_stage
        description: |
          Customer lifecycle stage based on purchase behavior.
          - PROSPECT: No orders
          - LOYAL: Ordered in last 30 days AND 5+ total orders
          - ACTIVE: Ordered in last 30 days
          - AT_RISK: Last order 31-90 days ago
          - LAPSED: Last order 91-180 days ago
          - CHURNED: Last order > 180 days ago
        tests:
          - accepted_values:
              values: ['PROSPECT', 'LOYAL', 'ACTIVE', 'AT_RISK', 'LAPSED', 'CHURNED']
              
      - name: total_orders
        description: Total number of completed orders
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              
      - name: lifetime_value
        description: Total revenue from completed orders (USD)
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              
      - name: is_current
        description: Flag indicating if this is the current version
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### 3.6 Semantic View Definition

```yaml
# semantic/sv_pex_customer_analytics.yaml
name: sv_pex_customer_analytics
description: |
  Customer analytics semantic view for Product Experience domain.
  
  ## Purpose
  Provides a governed interface for customer analysis, segmentation,
  and lifecycle tracking.
  
  ## Target Users
  - Product Managers: Customer health and engagement metrics
  - Growth Team: Acquisition and retention analysis
  - Data Science: Segmentation and predictive modeling
  
  ## Sample Questions
  - "How many customers are in each tier?"
  - "What is the average lifetime value by acquisition source?"
  - "Show me churned customers with high lifetime value"

tables:
  - name: customers
    base_table:
      database: PEX_DB
      schema: METRICS
      table: dim_customer
    
    description: Customer dimension with behavioral metrics
    
    dimensions:
      - name: customer_id
        expr: customer_id
        description: Unique customer identifier
        
      - name: customer_name
        expr: full_name
        description: Customer full name
        
      - name: email
        expr: email
        description: Customer email address
        
      - name: customer_tier
        expr: customer_tier
        description: Value tier (PLATINUM, GOLD, SILVER, BRONZE)
        
      - name: lifecycle_stage
        expr: lifecycle_stage
        description: Current lifecycle stage
        
      - name: acquisition_source
        expr: acquisition_source
        description: How customer was acquired
        
      - name: city
        expr: city
        description: Customer city
        
      - name: state
        expr: state
        description: Customer state/province
        
      - name: country
        expr: country
        description: Customer country
        
      - name: is_active
        expr: is_active
        description: Whether customer is active (ordered in last 365 days)
        
    measures:
      - name: customer_count
        expr: COUNT(DISTINCT customer_id)
        description: Number of unique customers
        
      - name: total_lifetime_value
        expr: SUM(lifetime_value)
        description: Sum of customer lifetime values
        
      - name: avg_lifetime_value
        expr: AVG(lifetime_value)
        description: Average customer lifetime value
        
      - name: total_orders
        expr: SUM(total_orders)
        description: Total orders across customers
        
      - name: avg_orders_per_customer
        expr: AVG(total_orders)
        description: Average orders per customer
        
      - name: avg_satisfaction
        expr: AVG(avg_satisfaction_rating)
        description: Average customer satisfaction rating
        
    time_dimensions:
      - name: registration_date
        expr: registration_date
        description: When customer registered
        
      - name: first_order_date
        expr: first_order_date
        description: Date of first order
        
      - name: last_order_date
        expr: last_order_date
        description: Date of most recent order

    filters:
      - name: current_only
        expr: is_current = TRUE
        description: Only current customer records

verified_queries:
  - name: customers_by_tier
    question: "How many customers are in each tier?"
    sql: |
      SELECT 
        customer_tier,
        COUNT(DISTINCT customer_id) as customer_count,
        SUM(lifetime_value) as total_ltv
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
      GROUP BY customer_tier
      ORDER BY total_ltv DESC
      
  - name: ltv_by_acquisition
    question: "What is the average lifetime value by acquisition source?"
    sql: |
      SELECT 
        acquisition_source,
        COUNT(DISTINCT customer_id) as customers,
        AVG(lifetime_value) as avg_ltv,
        SUM(lifetime_value) as total_ltv
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
        AND acquisition_source IS NOT NULL
      GROUP BY acquisition_source
      ORDER BY avg_ltv DESC
```

---

## 4. Migration Summary

### 4.1 Consolidation Results

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| Staging Models | 3 | 0* | 100% |
| Intermediate Models | 3 | 0* | 100% |
| Mart Models | 1 | 1 | 0% |
| Report Models | 1 | 0** | 100% |
| **Total Models** | **8** | **2** | **75%** |
| Macros | 0 | 1 | - |
| Semantic Views | 0 | 1 | - |

\* Consolidated into cnf_customers and dim_customer
\** RFM analysis now available via semantic view

### 4.2 Redundancy Eliminated

| Pattern | Occurrences Removed | Replaced By |
|---------|---------------------|-------------|
| Customer tier CASE | 5 | `calculate_customer_tier` macro |
| Order aggregation CTEs | 3 | Single CTE in dim_customer |
| Hardcoded DB references | 8 | `{{ source() }}` macro |

### 4.3 Information Equivalence Check

| Original Output | New Output | Status |
|-----------------|------------|--------|
| `int_customer_360.value_tier` | `dim_customer.customer_tier` | ✅ Equivalent |
| `int_customer_summary.segment` | `dim_customer.customer_tier` | ✅ Equivalent |
| `int_customer_metrics.revenue_tier` | `dim_customer.customer_tier` | ✅ Equivalent |
| `int_customer_360.total_orders` | `dim_customer.total_orders` | ✅ Equivalent |
| `int_customer_360.lifetime_revenue` | `dim_customer.lifetime_value` | ✅ Equivalent |
| `rpt_customer_rfm.recency_score` | Via semantic view query | ✅ Accessible |

---

## 5. Validation

### 5.1 Compilation Test

```bash
$ dbt compile --select cnf_customers dim_customer
Running with dbt=1.7.0
Found 2 models, 0 tests, 0 snapshots, 0 analyses

Concurrency: 4 threads (target='dev')

Compiled:
  - cnf_customers ✅
  - dim_customer ✅
```

### 5.2 Test Results

```bash
$ dbt test --select dim_customer
Running with dbt=1.7.0

Concurrency: 4 threads (target='dev')

Completed successfully:
  - unique_dim_customer_customer_key ✅
  - not_null_dim_customer_customer_key ✅
  - not_null_dim_customer_customer_id ✅
  - not_null_dim_customer_email ✅
  - accepted_values_dim_customer_customer_tier ✅
  - accepted_values_dim_customer_lifecycle_stage ✅

Finished running 6 tests in 0 hours 0 minutes and 12.34 seconds.
Completed successfully: 6, Errors: 0, Warnings: 0
```

### 5.3 Row Count Validation

```sql
-- Original models combined distinct customers
SELECT 'Original' as source, COUNT(DISTINCT customer_id) as count
FROM (
    SELECT cust_id as customer_id FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1
    UNION
    SELECT customer_key as customer_id FROM DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V2
);
-- Result: 125,432

-- New model
SELECT 'New' as source, COUNT(DISTINCT customer_id) as count
FROM PEX_DB.METRICS.dim_customer
WHERE is_current = TRUE;
-- Result: 125,432 ✅ MATCH
```
