# Print (PRT) Domain Rules

## Business Context
- **Owns**: Print services, fulfillment, production, shipping, inventory
- **Stakeholders**: Print operations, fulfillment centers, supply chain
- **Data Sensitivity**: Medium (contains order details, shipping addresses)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.PRINT` | Yes |
| Order grain | Order line item | Yes |
| Order identifier | `print_order_id` | Yes |
| Product identifier | `sku` | Yes |
| Facility identifier | `facility_id` | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_prt_` | cnf_prt_orders |
| Dimension | `dim_` | dim_product, dim_facility |
| Fact | `fact_prt_` | fact_prt_production |
| Semantic | `sv_prt_` | sv_prt_fulfillment |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_print_product | Type 2 | sku, product_name, product_type, paper_type, size |
| dim_facility | Type 2 | facility_id, facility_name, region, capacity |
| dim_carrier | Type 1 | carrier_id, carrier_name, service_level |
| dim_customer | Type 2 | customer_id, shipping_country, customer_tier |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_prt_orders | One row per order line | quantity, unit_cost, total_cost |
| fact_prt_production | One row per production job | print_time_mins, setup_time_mins, waste_sheets |
| fact_prt_shipments | One row per shipment | shipping_cost, delivery_days, is_on_time |
| fact_prt_inventory | One row per sku per facility per day | quantity_on_hand, quantity_reserved |

## Business Logic Defaults

### Order Priority
```sql
CASE
    WHEN shipping_method = 'EXPRESS' THEN 'P1'
    WHEN shipping_method = 'PRIORITY' THEN 'P2'
    WHEN order_date < DATEADD(day, -3, CURRENT_DATE) THEN 'P2'
    ELSE 'P3'
END
```

### Production Efficiency
```sql
-- Yield Rate
(total_sheets - waste_sheets) / NULLIF(total_sheets, 0) AS yield_rate

-- Utilization
actual_print_time / NULLIF(available_time, 0) AS utilization_rate

-- OEE (Overall Equipment Effectiveness)
availability * performance * quality AS oee
```

### Fulfillment SLA
| Service Level | Target Days |
|---------------|-------------|
| Express | 1 |
| Priority | 3 |
| Standard | 7 |
| Economy | 14 |

### Product Categories
| Category | Products |
|----------|----------|
| Cards | Greeting cards, business cards, postcards |
| Prints | Photos, posters, canvas |
| Books | Photo books, calendars, yearbooks |
| Marketing | Flyers, brochures, banners |

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | All surrogate keys, order_line_id |
| Not null | 100% | order_id, sku, facility_id |
| Accepted values | shipping_method | EXPRESS, PRIORITY, STANDARD, ECONOMY |
| Positive values | > 0 | quantity, costs |
| Ratio bounds | 0-1 | yield_rate, utilization_rate |

## Incremental Strategy
- **Default**: Merge on surrogate key
- **Lookback**: 7 days (for shipping updates)
- **Unique key**: order_line_id or shipment_id

## Notes
- Print orders often span multiple production stages
- Inventory snapshots should be taken daily
- Shipping data may update for days after dispatch (tracking)
- Consider facility timezone for production metrics
- Waste/yield metrics are critical for cost optimization
