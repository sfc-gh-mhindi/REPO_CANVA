# DBT Monolith to Federated Domain Migration Rules

## 1. Organisation Context

### Domain Structure
The organisation operates with multiple data domains, each representing a specific business area. The objective is to decompose a centralized data monolith into domain-owned assets, where each domain owns:
- Their own piece of the current database
- Their own portion of the 5000+ DBT model monolith
- Clear domain ownership with designated domain owners

### In-Scope Domains

| Domain | Abbreviation | Description |
|--------|--------------|-------------|
| Product Experience | `pex` | User engagement, product health, feature usage |
| Monetisation | `mon` | Revenue, billing, subscriptions, payments |
| Marketing | `mkt` | Campaigns, acquisition, attribution |
| IT | `it` | Infrastructure, systems, operations |
| Print | `prt` | Print services, fulfillment, production |
| Pilot | `plt` | Experimental features, A/B tests, pilots |

> **Scope Restriction**: This skill is restricted to these six domains only. Other domains are out of scope.

---

## 2. Current State Architecture

### Source System
- **DBT Project Name**: `transform`
- **Model Count**: 5,000+ models
- **Ownership Model**: Co-owned and co-used by all domains (no clear ownership boundaries)

### Current Problems

| Issue | Description | Impact |
|-------|-------------|--------|
| **Monolithic Structure** | Single DBT project contains all 5,000+ models | No domain autonomy |
| **No Domain Ownership** | Models are co-owned with unclear responsibilities | Accountability gaps |
| **High Redundancy** | Significant duplication of logic across models | Maintenance burden |
| **No Data Modeling Standard** | Tables not following dimensional, 3NF, or any consistent format | Inconsistent semantics |
| **Mixed Concerns** | Staging, temporary, and final tables intermingled | Confusion, tech debt |
| **Single Target Database** | All transformed data loads into one database | No domain separation |

### Current Data Flow
```
┌─────────────────────────────────────────────────────────────────┐
│                    SOURCE TABLES                                 │
│              (Snowflake Account - Raw Data)                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    transform (DBT Project)                       │
│                     5,000+ DBT Models                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ Staging  │ │   Temp   │ │   Int    │ │  Final   │           │
│  │ Tables   │ │  Tables  │ │  Tables  │ │  Tables  │           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
│                   (All intermingled, no structure)              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                 SINGLE TARGET DATABASE                           │
│           (Unstructured mix of all domain tables)               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Target Data Architecture

### Three-Layer Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SEMANTIC LAYER                                      │
│         Governed AI-ready interface via Snowflake Intelligence               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  • Semantic Views ONLY (no physical tables)                          │    │
│  │  • Conversational AI interface via Snowflake Intelligence           │    │
│  │  • BI and Analytics tool integration                                 │    │
│  │  • Governed business definitions                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ▲
                              Reads from
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                           METRICS LAYER                                       │
│              Star Schema Dimensional Models for Reporting                    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  • Dimension tables (dim_*)                                          │    │
│  │  • Fact tables (fact_*)                                              │    │
│  │  • Optimized for analytical queries                                  │    │
│  │  • Domain-specific business metrics                                  │    │
│  │  • Example: Product health, user engagement for PEX domain          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ▲
                              Reads from
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONFORMED LAYER                                      │
│            Reusable Event-Level Facts and Entity Models                      │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  • Event-level facts (cnf_*) - domain interactions at grain level   │    │
│  │  • Entity dimensions (cnf_*) - canonical entity definitions         │    │
│  │  • Cross-domain reusable assets                                      │    │
│  │  • Lowest level of detail (transaction/event grain)                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ▲
                           Referenced via {{ source() }}
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SOURCE LAYER                                        │
│                   Raw Source Data from Snowflake                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layer Specifications

#### 3.1 Conformed Layer (`cnf_`)

| Attribute | Specification |
|-----------|---------------|
| **Purpose** | Reusable event-level facts and entity models |
| **Prefix** | `cnf_` |
| **Grain** | Lowest level of detail (transaction/event level) |
| **Ownership** | Shared asset, governed centrally |

**Content Types:**
- Event-level facts for domain interactions
- Entity dimensions shared across domains
- Canonical definitions of business entities

**Example Models:**
```
cnf_user_events      - All user interaction events
cnf_customers        - Master customer entity
cnf_products         - Master product entity  
cnf_transactions     - Transaction-level events
cnf_subscriptions    - Subscription events
```

#### 3.2 Metrics Layer (`dim_`, `fact_`)

| Attribute | Specification |
|-----------|---------------|
| **Purpose** | Reporting-oriented dimensional models (star schema) |
| **Prefix** | `dim_` for dimensions, `fact_` for facts |
| **Structure** | Star schema |
| **Ownership** | Domain-owned |

**Content Types:**
- Dimension tables with descriptive attributes
- Fact tables with measures and foreign keys
- Domain-specific aggregations and metrics

**Use Case Example (Product Experience Domain):**
- Answer product health questions
- Track user engagement metrics
- Support Product, Growth, and Data Science teams

**Example Models:**
```
dim_customer         - Customer dimension (SCD Type 2 if applicable)
dim_product          - Product dimension
dim_date             - Date/calendar dimension
fact_orders          - Order fact at line-item grain
fact_user_sessions   - Session-level metrics
fact_subscriptions   - Subscription metrics
```

#### 3.3 Semantic Layer (Semantic Views Only)

| Attribute | Specification |
|-----------|---------------|
| **Purpose** | Governed, AI-ready interface for end users |
| **Object Type** | Snowflake Semantic Views ONLY |
| **Source** | Reads EXCLUSIVELY from Metrics Layer |
| **Interface** | Snowflake Intelligence (conversational AI), BI tools |

**Example Semantic Views:**
```
sv_sales_analytics       - Sales semantic view
sv_customer_insights     - Customer semantic view
sv_product_metrics       - Product semantic view
sv_subscription_health   - Subscription semantic view
```

---

## 4. Target DBT Architecture

### 4.1 Project Structure

Each domain owns an independent DBT project:

```
domain_dbt_projects/
├── pex_transform/                  # Product Experience Domain
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── models/
│   │   ├── staging/                # Staging models (use source())
│   │   │   └── schema.yml          # Source definitions
│   │   ├── conformed/              # cnf_* models
│   │   │   └── schema.yml
│   │   ├── metrics/                # dim_* and fact_* models
│   │   │   └── schema.yml
│   │   └── semantic/               # Semantic view definitions
│   │       └── schema.yml
│   ├── macros/                     # Domain-specific macros
│   ├── tests/                      # Custom tests
│   ├── seeds/                      # Static data
│   └── docs/                       # Documentation
│       ├── domain_overview.md
│       ├── data_dictionary.md
│       └── lineage.md
│
├── mon_transform/                  # Monetisation Domain
├── mkt_transform/                  # Marketing Domain
├── it_transform/                   # IT Domain
├── prt_transform/                  # Print Domain
├── plt_transform/                  # Pilot Domain
│
└── shared_macros/                  # Cross-domain reusable macros
    ├── macros/
    │   ├── tier_logic/
    │   │   ├── calculate_customer_tier.sql
    │   │   ├── calculate_order_tier.sql
    │   │   └── calculate_product_tier.sql
    │   ├── date_helpers/
    │   │   ├── fiscal_year.sql
    │   │   ├── fiscal_quarter.sql
    │   │   └── fiscal_month.sql
    │   └── margins/
    │       ├── gross_margin.sql
    │       └── margin_pct.sql
    └── dbt_project.yml
```

### 4.2 Key Architecture Principles

| Principle | Requirement | Rationale |
|-----------|-------------|-----------|
| **No Redundancy** | Eliminate duplicate models; consolidate into single source of truth | Reduce maintenance, ensure consistency |
| **Macro Extraction** | Convert repeated logic into reusable macros | DRY principle, consistency |
| **No Legacy Table Preservation** | Target tables follow NEW architecture, NOT original structures | Clean break from monolith |
| **Information Equivalence** | Output must reproduce same INFORMATION, different STRUCTURE | Maintain business capability |
| **Domain Ownership** | Each domain owns and maintains their DBT project | Clear accountability |

### 4.3 Model Transformation Rule

> **CRITICAL**: There is NO requirement to maintain target table structures.

**Transformation Principle:**
- Models should regenerate the same OUTCOME in terms of INFORMATION
- Models should target the NEW data architecture
- Original table structures are NOT preserved

**Example:**
```
CURRENT STATE:                      TARGET STATE:
┌─────────────────┐                ┌─────────────────┐
│    customers    │    ──────►    │  dim_customers  │
│  (single table) │                ├─────────────────┤
└─────────────────┘                │ fact_customer_  │
                                   │    orders       │
                                   └─────────────────┘

❌ DO NOT create models targeting original "customers" table
✅ DO create dim_customers and fact_customer_orders
```

---

## 5. Naming Conventions

### 5.1 Model Prefixes by Layer

| Layer | Prefix | Pattern | Examples |
|-------|--------|---------|----------|
| Staging | `stg_` | `stg_{source}_{entity}` | `stg_raw_customers`, `stg_raw_orders` |
| Conformed | `cnf_` | `cnf_{entity}` | `cnf_users`, `cnf_events`, `cnf_products` |
| Metrics - Dimensions | `dim_` | `dim_{entity}` | `dim_customer`, `dim_product`, `dim_date` |
| Metrics - Facts | `fact_` | `fact_{process/event}` | `fact_orders`, `fact_sessions`, `fact_revenue` |
| Semantic | `sv_` | `sv_{domain}_{purpose}` | `sv_sales_analytics`, `sv_customer_insights` |

### 5.2 Column Naming Standards

| Type | Convention | Examples |
|------|------------|----------|
| Primary Key (Surrogate) | `{entity}_key` | `customer_key`, `product_key` |
| Natural Key / Business Key | `{entity}_id` | `customer_id`, `order_id` |
| Foreign Key | `{parent_entity}_key` | `customer_key` (in fact table) |
| Date Column | `{event}_date` | `order_date`, `created_date` |
| Timestamp Column | `{event}_at` | `created_at`, `updated_at` |
| Boolean Flag | `is_{condition}` | `is_active`, `is_deleted` |
| Amount/Currency | `{metric}_amount` | `order_amount`, `refund_amount` |
| Count Metric | `{metric}_count` | `order_count`, `item_count` |
| Percentage | `{metric}_pct` | `margin_pct`, `discount_pct` |

### 5.3 File Naming Standards

| Type | Convention | Example |
|------|------------|---------|
| Model File | `{prefix}_{entity}.sql` | `dim_customer.sql`, `fact_orders.sql` |
| Macro File | `{function_name}.sql` | `calculate_tier.sql`, `fiscal_year.sql` |
| Custom Test | `test_{test_name}.sql` | `test_order_amount_positive.sql` |
| Schema Definition | `schema.yml` | (in each model directory) |

---

## 6. Source Reference Requirements

### 6.1 Mandatory Source Usage

**ALL staging models MUST use `{{ source() }}` macro**

```sql
-- ✅ CORRECT: Use source() macro for all raw data references
SELECT 
    customer_id,
    customer_name,
    email
FROM {{ source('raw', 'customers') }}

-- ❌ WRONG: Direct database.schema.table references
SELECT 
    customer_id,
    customer_name,
    email
FROM RAW_DB.RAW_SCHEMA.CUSTOMERS
```

### 6.2 Source Definition Structure

All sources must be defined in `models/staging/schema.yml`:

```yaml
version: 2

sources:
  - name: raw
    description: Raw source data from operational systems
    database: "{{ var('raw_database', 'RAW_DB') }}"
    schema: "{{ var('raw_schema', 'RAW_SCHEMA') }}"
    tables:
      - name: customers
        description: Raw customer master data
        columns:
          - name: customer_id
            description: Unique customer identifier
            tests:
              - unique
              - not_null
      - name: orders
        description: Raw order transactions
      - name: products
        description: Raw product catalog
```

---

## 7. Macro Requirements

### 7.1 Tier Logic Macros

#### Customer Tier
```sql
-- macros/tier_logic/calculate_customer_tier.sql
{% macro calculate_customer_tier(lifetime_value) %}
CASE
    WHEN {{ lifetime_value }} >= 10000 THEN 'PLATINUM'
    WHEN {{ lifetime_value }} >= 5000 THEN 'GOLD'
    WHEN {{ lifetime_value }} >= 1000 THEN 'SILVER'
    ELSE 'BRONZE'
END
{% endmacro %}
```

#### Order Tier
```sql
-- macros/tier_logic/calculate_order_tier.sql
{% macro calculate_order_tier(order_amount) %}
CASE
    WHEN {{ order_amount }} >= 1000 THEN 'HIGH_VALUE'
    WHEN {{ order_amount }} >= 500 THEN 'MEDIUM_VALUE'
    WHEN {{ order_amount }} >= 100 THEN 'LOW_VALUE'
    ELSE 'MICRO'
END
{% endmacro %}
```

#### Product Tier
```sql
-- macros/tier_logic/calculate_product_tier.sql
{% macro calculate_product_tier(revenue) %}
CASE
    WHEN {{ revenue }} >= 100000 THEN 'STAR'
    WHEN {{ revenue }} >= 50000 THEN 'PERFORMER'
    WHEN {{ revenue }} >= 10000 THEN 'STEADY'
    ELSE 'UNDERPERFORMER'
END
{% endmacro %}
```

### 7.2 Date Helper Macros

#### Fiscal Year
```sql
-- macros/date_helpers/fiscal_year.sql
{% macro fiscal_year(date_column, fiscal_year_start_month=7) %}
CASE
    WHEN MONTH({{ date_column }}) >= {{ fiscal_year_start_month }}
    THEN YEAR({{ date_column }}) + 1
    ELSE YEAR({{ date_column }})
END
{% endmacro %}
```

#### Fiscal Quarter
```sql
-- macros/date_helpers/fiscal_quarter.sql
{% macro fiscal_quarter(date_column, fiscal_year_start_month=7) %}
CASE
    WHEN MONTH({{ date_column }}) >= {{ fiscal_year_start_month }}
    THEN CEIL((MONTH({{ date_column }}) - {{ fiscal_year_start_month }} + 1) / 3.0)
    ELSE CEIL((MONTH({{ date_column }}) + 12 - {{ fiscal_year_start_month }} + 1) / 3.0)
END
{% endmacro %}
```

#### Fiscal Month
```sql
-- macros/date_helpers/fiscal_month.sql
{% macro fiscal_month(date_column, fiscal_year_start_month=7) %}
CASE
    WHEN MONTH({{ date_column }}) >= {{ fiscal_year_start_month }}
    THEN MONTH({{ date_column }}) - {{ fiscal_year_start_month }} + 1
    ELSE MONTH({{ date_column }}) + 12 - {{ fiscal_year_start_month }} + 1
END
{% endmacro %}
```

### 7.3 Margin Calculation Macros

#### Gross Margin
```sql
-- macros/margins/gross_margin.sql
{% macro gross_margin(revenue, cost) %}
({{ revenue }} - {{ cost }})
{% endmacro %}
```

#### Margin Percentage
```sql
-- macros/margins/margin_pct.sql
{% macro margin_pct(revenue, cost) %}
CASE
    WHEN {{ revenue }} = 0 THEN 0
    ELSE ROUND(({{ revenue }} - {{ cost }}) / NULLIF({{ revenue }}, 0) * 100, 2)
END
{% endmacro %}
```

---

## 8. Testing Requirements

### 8.1 Primary Key Tests

**All primary keys MUST have:**
- `unique` test
- `not_null` test

```yaml
models:
  - name: dim_customer
    columns:
      - name: customer_key
        description: Surrogate key for customer dimension
        tests:
          - unique
          - not_null
```

### 8.2 Foreign Key Tests

**All foreign keys MUST have:**
- `not_null` test
- `relationships` test to parent table

```yaml
models:
  - name: fact_orders
    columns:
      - name: customer_key
        description: Foreign key to dim_customer
        tests:
          - not_null
          - relationships:
              to: ref('dim_customer')
              field: customer_key
      - name: product_key
        description: Foreign key to dim_product
        tests:
          - not_null
          - relationships:
              to: ref('dim_product')
              field: product_key
```

### 8.3 Business Rule Tests

**Custom tests for data quality:**

```yaml
models:
  - name: fact_orders
    columns:
      - name: order_amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: quantity
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
      - name: order_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
```

### 8.4 Minimum Test Coverage Matrix

| Model Type | Required Tests |
|------------|---------------|
| **Dimension** | PK: unique + not_null; All NKs: not_null |
| **Fact** | PK: unique + not_null; All FKs: relationship + not_null; Measures: >= 0 where applicable |
| **Conformed** | PK: unique + not_null; Event timestamps: not_null |
| **Staging** | Source freshness where applicable |

---

## 9. Data Migration

### 9.1 Migration Script Generation

The skill MUST ask the user if they want to generate a migration script that:
- Migrates information from current data model to new data model
- Handles data type conversions
- Maps old columns to new structure
- Validates data integrity post-migration

### 9.2 Migration Script Template

```sql
-- Migration script: {source_table} → {target_table(s)}
-- Generated: {timestamp}
-- Domain: {domain}

-- Step 1: Create target tables (if not exists)
{ddl_statements}

-- Step 2: Migrate data
INSERT INTO {target_schema}.{target_table}
SELECT 
    {column_mappings}
FROM {source_schema}.{source_table}
WHERE {filter_conditions};

-- Step 3: Validate migration
SELECT 
    '{source_table}' as source_table,
    '{target_table}' as target_table,
    (SELECT COUNT(*) FROM {source_schema}.{source_table}) as source_count,
    (SELECT COUNT(*) FROM {target_schema}.{target_table}) as target_count,
    CASE 
        WHEN source_count = target_count THEN 'PASSED'
        ELSE 'FAILED - COUNT MISMATCH'
    END as validation_status;
```

---

## 10. Required Outputs

The skill MUST generate the following outputs:

### 10.1 DDL - New Table Structure
- Complete DDL for all new tables in target data model
- Includes all layers: conformed, metrics
- Proper data types, constraints, clustering keys

### 10.2 New DBT Project
- Complete, compilable DBT project
- All models, macros, tests, and configurations
- Ready for `dbt compile` and `dbt run`

### 10.3 Documentation Requirements

#### 10.3.1 Domain Overview (`docs/domain_overview.md`)
- Executive summary providing context for domain's data assets
- Scope and boundaries
- Key stakeholders
- Business objectives

#### 10.3.2 Data Dictionary (`docs/data_dictionary.md`)
- Column-level documentation for ALL models in each layer
- Data types, business definitions, example values
- Nullable/required indicators

#### 10.3.3 Lineage Documentation (`docs/lineage.md`)
- Data flow documentation
- Dependencies between models
- Transformation logic summary

#### 10.3.4 DBT Project Specifications (`docs/dbt_project_spec.md`)
- Project configuration details
- Variable definitions
- Profile requirements
- Package dependencies

#### 10.3.5 Semantic View Specifications (`docs/semantic_view_spec.md`)
- Semantic view definitions
- Dimension and measure specifications
- Relationship definitions
- Business logic documentation

#### 10.3.6 Migration Report (`docs/migration_report.md`)
- Summary of models analyzed
- Redundancy findings
- Models consolidated
- Models created
- Macros extracted
- Breaking changes (if any)

### 10.4 Optional - Data Migration Scripts
- Only generated if user requests
- Full migration scripts from current to target state
- Validation queries

---

## 11. Skill Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: DOMAIN SELECTION                                                    │
│  • Prompt user to select target domain (pex/mon/mkt/it/prt/plt)            │
│  • Confirm domain scope                                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 2: INPUT ANALYSIS                                                      │
│  • Accept DBT models (SQL files) or model names                             │
│  • Accept source table DDLs or describe from Snowflake                      │
│  • Map dependencies and lineage                                              │
│  • Detect redundancies and duplicates                                        │
│  • Identify repeated logic for macro extraction                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 3: DESIGN & PLANNING                                                   │
│  • Design conformed layer entities                                          │
│  • Design metrics layer star schema                                          │
│  • Plan semantic views                                                       │
│  • Define macro library                                                      │
│  • Present design for user approval                                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 4: GENERATION                                                          │
│  • Generate DDL for new table structures                                    │
│  • Generate source definitions                                               │
│  • Generate conformed layer models (cnf_*)                                  │
│  • Generate metrics layer models (dim_*, fact_*)                            │
│  • Generate semantic view definitions                                        │
│  • Generate macros                                                           │
│  • Generate tests                                                            │
│  • Generate documentation                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 5: MIGRATION OPTION                                                    │
│  • Ask user: "Do you want to generate migration scripts?"                   │
│  • If yes: Generate data migration scripts                                  │
│  • If no: Skip migration script generation                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 6: VALIDATION & OUTPUT                                                 │
│  • Compile DBT project                                                       │
│  • Verify all outputs generated                                              │
│  • Present summary to user                                                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Success Criteria

| Criteria | Measurement | Required |
|----------|-------------|----------|
| **Zero Redundancy** | No duplicate models producing same output | ✅ |
| **Layer Compliance** | All models follow 3-layer architecture | ✅ |
| **Naming Compliance** | 100% adherence to naming conventions | ✅ |
| **Source Compliance** | All raw references use `{{ source() }}` | ✅ |
| **Test Coverage** | All PKs, FKs, and business rules tested | ✅ |
| **Macro Utilization** | All repeated logic extracted to macros | ✅ |
| **Information Equivalence** | New models reproduce all original information | ✅ |
| **Domain Ownership** | Clear ownership assignment for all models | ✅ |
| **Documentation Complete** | All 6 documentation outputs generated | ✅ |
| **Compilable Project** | DBT project compiles without errors | ✅ |
