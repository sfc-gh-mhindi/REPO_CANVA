# Monetisation (MON) Domain Rules

## Business Context
- **Owns**: Revenue, billing, subscriptions, payments, pricing
- **Stakeholders**: Finance, revenue operations, billing teams
- **Data Sensitivity**: High (contains financial data, payment info)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.BILLING` | Yes |
| Transaction grain | Invoice line item | Yes |
| Customer identifier | `customer_id` | Yes |
| Currency | Multi-currency, normalize to USD | Yes |
| Revenue recognition | Accrual basis | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_mon_` | cnf_mon_transactions |
| Dimension | `dim_` | dim_customer, dim_product |
| Fact | `fact_mon_` | fact_mon_revenue |
| Semantic | `sv_mon_` | sv_mon_revenue_analytics |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_customer | Type 2 | customer_id, customer_name, billing_country, customer_tier |
| dim_subscription | Type 2 | subscription_id, plan_name, billing_cycle, status |
| dim_product | Type 1 | product_id, product_name, product_line, pricing_tier |
| dim_currency | Type 1 | currency_code, exchange_rate_to_usd |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_mon_revenue | One row per invoice line | gross_amount, discount_amount, net_amount, tax_amount |
| fact_mon_subscriptions | One row per subscription per day | mrr, arr, is_active |
| fact_mon_payments | One row per payment | payment_amount, refund_amount |

## Business Logic Defaults

### Customer Tier Calculation
```sql
CASE
    WHEN lifetime_revenue >= 100000 THEN 'ENTERPRISE'
    WHEN lifetime_revenue >= 10000 THEN 'BUSINESS'
    WHEN lifetime_revenue >= 1000 THEN 'PROFESSIONAL'
    ELSE 'STARTER'
END
```

### MRR Calculation
```sql
CASE 
    WHEN billing_cycle = 'MONTHLY' THEN subscription_amount
    WHEN billing_cycle = 'ANNUAL' THEN subscription_amount / 12
    WHEN billing_cycle = 'QUARTERLY' THEN subscription_amount / 3
END
```

### Revenue Recognition
| Type | Rule |
|------|------|
| Subscription | Recognize monthly over term |
| One-time | Recognize at invoice date |
| Usage-based | Recognize at consumption |

### Fiscal Calendar
| Setting | Default |
|---------|---------|
| Fiscal year start | July 1 |
| Fiscal quarters | Q1=Jul-Sep, Q2=Oct-Dec, Q3=Jan-Mar, Q4=Apr-Jun |

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | All surrogate keys, invoice_id |
| Not null | 100% | customer_id, amount fields, dates |
| Accepted values | currency_code | ISO 4217 codes |
| Positive values | >= 0 | All amount fields |
| Reconciliation | ±0.01 | Monthly totals vs source |

## Incremental Strategy
- **Default**: Merge on surrogate key
- **Lookback**: 7 days (for payment adjustments)
- **Unique key**: transaction_id or invoice_line_id

## Notes
- Financial data requires strict accuracy
- Always maintain audit trail
- Currency conversion rates should be snapshot at transaction time
- Consider separate exchange rate dimension for historical analysis
