# Messy E-Commerce DBT Project

## Purpose

This is an **intentionally poorly designed** DBT project created to test the Data Model Modernization Skill. It contains numerous anti-patterns and issues that need to be refactored.

## Source Tables (12 tables in `DBT_REFACTOR_TEST.RAW`)

| Table | Description | Issues |
|-------|-------------|--------|
| `raw_orders` | Massively denormalized orders | Customer, product, shipping, payment all embedded |
| `raw_transactions` | Financial transactions | Overlaps with orders, different structure |
| `raw_customers_v1` | Legacy customer data | Computed fields stored, delimited preferences |
| `raw_customers_v2` | New customer data | Different structure, overlapping data |
| `raw_products_flat` | Product catalog | Category hierarchy flattened, inventory embedded |
| `raw_inventory_log` | Inventory movements | Product/warehouse info repeated every row |
| `raw_shipping_events` | Shipping events | Customer/order info repeated per event |
| `raw_returns` | Returns data | All related info embedded |
| `raw_marketing_campaigns` | Campaign data | Metrics and segments embedded |
| `raw_clickstream` | Web events | Session/user/device info repeated |
| `raw_support_tickets` | Support tickets | Customer/SLA info embedded |
| `raw_employee_sales` | Sales by employee | Employee/store/quota all repeated |

## DBT Models (50 models across 6 layers)

### Staging Layer (17 models)
- Multiple duplicate stagings for same source (`stg_orders`, `stg_orders_v2`, `stg_orders_completed`)
- Inconsistent column naming across models
- Hardcoded database references
- Union logic in staging instead of intermediate

### Intermediate Layer (10 models)
- Three different customer aggregations (`int_customer_360`, `int_customer_summary`, `int_customer_metrics`)
- Two product summaries (`int_product_performance`, `int_product_summary`)
- Massive CTEs with repeated logic
- Direct raw table references instead of staging

### Marts Layer (10 models)
- Facts with embedded dimension attributes
- Multiple overlapping fact tables
- Dimensions built from wrong sources

### Reports Layer (8 models)
- Direct raw table queries
- Duplicate aggregation logic
- Re-implementing business rules

### Analytics Layer (5 models)
- Duplicating mart logic
- Complex inline calculations
- Re-segmenting customers

### Aggregates Layer (7 models)
- Re-reading raw data
- Duplicating staging/intermediate logic
- Warehouse info repeated

## Key Anti-Patterns Present

1. **Duplicate Models**: Same data modeled 2-3x differently
2. **Hardcoded Values**: Date ranges, tier thresholds scattered throughout
3. **Inconsistent Naming**: `ord_id`, `order_id`, `id` for same concept
4. **Tier Logic Repeated**: Customer/order tiers calculated 5+ different ways
5. **No Macros**: Common patterns repeated inline
6. **Raw Table Access**: Reports/aggregates bypass staging layer
7. **Mixed Granularities**: Single table combines fact and dimension data
8. **No Source Definitions**: Direct database.schema.table references

## Ideal Target State (Star Schema)

### Conformed Layer (3NF)
- `conf_customers` - Unified customer master
- `conf_products` - Product master with proper category hierarchy
- `conf_locations` - Warehouses, stores, regions
- `conf_employees` - Employee master with hierarchy

### Dimensional Layer
- `dim_customer` - Customer dimension with SCD
- `dim_product` - Product dimension
- `dim_date` - Date dimension
- `dim_location` - Location dimension
- `dim_employee` - Employee dimension
- `fct_orders` - Order line fact
- `fct_inventory` - Inventory snapshot fact
- `fct_web_sessions` - Session fact
- `fct_support` - Support ticket fact

### Semantic Layer
- Snowflake Semantic Views for each business domain
