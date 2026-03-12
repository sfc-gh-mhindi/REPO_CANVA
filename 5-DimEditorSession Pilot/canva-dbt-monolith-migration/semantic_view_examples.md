# Snowflake Semantic View Examples

This document provides detailed examples of Snowflake semantic view YAML definitions for different use cases.

---

## 1. Semantic View Overview

### 1.1 What is a Semantic View?

A Snowflake Semantic View provides:
- A governed, business-friendly interface over dimensional models
- Natural language query capability via Snowflake Intelligence
- Consistent metric definitions across the organization
- Self-service analytics for business users

### 1.2 Core Components

| Component | Purpose | Required |
|-----------|---------|----------|
| `name` | Unique identifier for the semantic view | ✅ |
| `description` | Business context and usage guidance | ✅ |
| `tables` | Base tables (facts and dimensions) | ✅ |
| `dimensions` | Attributes for filtering and grouping | ✅ |
| `measures` | Aggregated metrics | ✅ |
| `time_dimensions` | Date/time columns for time-series analysis | ✅ |
| `joins` | Relationships between tables | When multiple tables |
| `filters` | Pre-defined filters/segments | ⚪ Optional |
| `verified_queries` | Sample SQL for common questions | Recommended |

---

## 2. Basic Semantic View Structure

```yaml
# semantic/sv_{domain}_{subject}.yaml

name: sv_{domain}_{subject}

description: |
  {Multi-line description}
  
  ## Purpose
  {What this semantic view enables}
  
  ## Target Users
  - {User group 1}
  - {User group 2}
  
  ## Sample Questions
  - "{Question 1}?"
  - "{Question 2}?"

tables:
  - name: {fact_table_alias}
    base_table:
      database: {DATABASE}
      schema: {SCHEMA}
      table: {TABLE_NAME}
    
    description: {Table description}
    
    dimensions:
      - name: {dimension_name}
        expr: {column_or_expression}
        description: {Business description}
        data_type: {VARCHAR|INTEGER|DATE|etc}
    
    measures:
      - name: {measure_name}
        expr: {aggregation_expression}
        description: {Business description}
        data_type: {INTEGER|DECIMAL|etc}
        default_aggregation: {SUM|COUNT|AVG|etc}
    
    time_dimensions:
      - name: {time_dimension_name}
        expr: {date_column}
        description: {Description}

joins:
  - name: {join_name}
    left_table: {left_alias}
    right_table: {right_alias}
    join_type: {left|inner|right}
    condition: "{join_condition}"

filters:
  - name: {filter_name}
    expr: "{filter_expression}"
    description: {When to use this filter}

verified_queries:
  - name: {query_name}
    question: "{Natural language question}"
    sql: |
      {SQL that answers the question}
```

---

## 3. Example: Customer Analytics Semantic View

### 3.1 Full YAML Definition

```yaml
# semantic/sv_pex_customer_analytics.yaml

name: sv_pex_customer_analytics

description: |
  Customer Analytics semantic view for the Product Experience domain.
  
  ## Purpose
  Provides a comprehensive view of customer behavior, value, and engagement
  for product health analysis, growth optimization, and customer success.
  
  ## Target Users
  - **Product Managers**: Track feature adoption and user engagement
  - **Growth Team**: Analyze acquisition, activation, and retention
  - **Customer Success**: Monitor customer health and identify at-risk accounts
  - **Data Science**: Build segmentation and predictive models
  
  ## Key Metrics Available
  - Customer counts by tier and lifecycle stage
  - Lifetime value and average order value
  - Engagement metrics (sessions, orders, support tickets)
  - Retention and churn indicators
  
  ## Sample Questions
  - "How many customers are in each tier?"
  - "What is the average lifetime value by acquisition source?"
  - "Show me churned customers with lifetime value over $5000"
  - "What is the monthly trend of new customer acquisitions?"

tables:
  - name: customers
    base_table:
      database: PEX_DB
      schema: METRICS
      table: dim_customer
    
    description: |
      Customer dimension containing profile data, behavioral metrics, 
      and calculated segments. One row per customer (current version only).
    
    dimensions:
      - name: customer_id
        expr: customer_id
        description: Unique identifier for the customer
        data_type: VARCHAR
        
      - name: customer_name
        expr: full_name
        description: Customer's full name (first + last)
        data_type: VARCHAR
        
      - name: email
        expr: email
        description: Customer email address
        data_type: VARCHAR
        
      - name: customer_tier
        expr: customer_tier
        description: |
          Value tier based on lifetime value:
          - PLATINUM: >= $10,000
          - GOLD: >= $5,000  
          - SILVER: >= $1,000
          - BRONZE: < $1,000
        data_type: VARCHAR
        
      - name: lifecycle_stage
        expr: lifecycle_stage
        description: |
          Current lifecycle stage:
          - PROSPECT: No orders yet
          - LOYAL: Active with 5+ orders
          - ACTIVE: Ordered within 30 days
          - AT_RISK: 31-90 days since last order
          - LAPSED: 91-180 days since last order
          - CHURNED: >180 days since last order
        data_type: VARCHAR
        
      - name: acquisition_source
        expr: acquisition_source
        description: Channel through which customer was acquired
        data_type: VARCHAR
        
      - name: acquisition_campaign
        expr: acquisition_campaign
        description: Marketing campaign that acquired the customer
        data_type: VARCHAR
        
      - name: city
        expr: city
        description: Customer's city
        data_type: VARCHAR
        
      - name: state
        expr: state
        description: Customer's state/province
        data_type: VARCHAR
        
      - name: country
        expr: country
        description: Customer's country
        data_type: VARCHAR
        
      - name: is_active
        expr: is_active
        description: Whether customer has ordered in the last 365 days
        data_type: BOOLEAN
        
      - name: account_status
        expr: account_status
        description: Current account status (ACTIVE, SUSPENDED, CLOSED)
        data_type: VARCHAR
        
    measures:
      - name: customer_count
        expr: COUNT(DISTINCT customer_id)
        description: Number of unique customers
        data_type: INTEGER
        default_aggregation: COUNT_DISTINCT
        
      - name: total_lifetime_value
        expr: SUM(lifetime_value)
        description: Sum of all customer lifetime values
        data_type: DECIMAL
        default_aggregation: SUM
        
      - name: avg_lifetime_value
        expr: AVG(lifetime_value)
        description: Average customer lifetime value
        data_type: DECIMAL
        default_aggregation: AVG
        
      - name: total_orders
        expr: SUM(total_orders)
        description: Total number of orders across all customers
        data_type: INTEGER
        default_aggregation: SUM
        
      - name: avg_orders_per_customer
        expr: AVG(total_orders)
        description: Average number of orders per customer
        data_type: DECIMAL
        default_aggregation: AVG
        
      - name: avg_order_value
        expr: AVG(avg_order_value)
        description: Average order value across customers
        data_type: DECIMAL
        default_aggregation: AVG
        
      - name: total_support_tickets
        expr: SUM(total_support_tickets)
        description: Total support tickets raised
        data_type: INTEGER
        default_aggregation: SUM
        
      - name: avg_satisfaction_rating
        expr: AVG(avg_satisfaction_rating)
        description: Average customer satisfaction score (1-5)
        data_type: DECIMAL
        default_aggregation: AVG
        
      - name: total_sessions
        expr: SUM(total_sessions)
        description: Total web sessions across all customers
        data_type: INTEGER
        default_aggregation: SUM
        
    time_dimensions:
      - name: registration_date
        expr: registration_date
        description: Date the customer registered
        
      - name: first_order_date
        expr: first_order_date
        description: Date of the customer's first order
        
      - name: last_order_date
        expr: last_order_date
        description: Date of the customer's most recent order

    filters:
      - name: current_only
        expr: is_current = TRUE
        description: Only include current customer records (excludes historical SCD2 versions)
        
      - name: active_customers
        expr: is_active = TRUE
        description: Only customers who have ordered in the last 365 days
        
      - name: high_value
        expr: customer_tier IN ('PLATINUM', 'GOLD')
        description: Only high-value customers (PLATINUM and GOLD tiers)

verified_queries:
  - name: customers_by_tier
    question: "How many customers are in each tier?"
    sql: |
      SELECT 
        customer_tier,
        COUNT(DISTINCT customer_id) AS customer_count,
        ROUND(SUM(lifetime_value), 2) AS total_ltv,
        ROUND(AVG(lifetime_value), 2) AS avg_ltv
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
      GROUP BY customer_tier
      ORDER BY 
        CASE customer_tier 
          WHEN 'PLATINUM' THEN 1 
          WHEN 'GOLD' THEN 2 
          WHEN 'SILVER' THEN 3 
          ELSE 4 
        END

  - name: customers_by_lifecycle
    question: "How many customers are in each lifecycle stage?"
    sql: |
      SELECT 
        lifecycle_stage,
        COUNT(DISTINCT customer_id) AS customer_count,
        ROUND(AVG(lifetime_value), 2) AS avg_ltv,
        ROUND(AVG(total_orders), 1) AS avg_orders
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
      GROUP BY lifecycle_stage
      ORDER BY 
        CASE lifecycle_stage
          WHEN 'LOYAL' THEN 1
          WHEN 'ACTIVE' THEN 2
          WHEN 'AT_RISK' THEN 3
          WHEN 'LAPSED' THEN 4
          WHEN 'CHURNED' THEN 5
          ELSE 6
        END

  - name: ltv_by_acquisition_source
    question: "What is the average lifetime value by acquisition source?"
    sql: |
      SELECT 
        COALESCE(acquisition_source, 'Unknown') AS acquisition_source,
        COUNT(DISTINCT customer_id) AS customers,
        ROUND(AVG(lifetime_value), 2) AS avg_ltv,
        ROUND(SUM(lifetime_value), 2) AS total_ltv
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
      GROUP BY acquisition_source
      ORDER BY avg_ltv DESC
      
  - name: churned_high_value
    question: "Show me churned customers with high lifetime value"
    sql: |
      SELECT 
        customer_id,
        full_name,
        email,
        customer_tier,
        lifetime_value,
        total_orders,
        last_order_date,
        days_since_last_order
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
        AND lifecycle_stage = 'CHURNED'
        AND lifetime_value >= 5000
      ORDER BY lifetime_value DESC
      LIMIT 100

  - name: monthly_new_customers
    question: "What is the monthly trend of new customer registrations?"
    sql: |
      SELECT 
        DATE_TRUNC('month', registration_date) AS month,
        COUNT(DISTINCT customer_id) AS new_customers,
        ROUND(AVG(lifetime_value), 2) AS avg_ltv_to_date
      FROM PEX_DB.METRICS.dim_customer
      WHERE is_current = TRUE
        AND registration_date >= DATEADD('month', -12, CURRENT_DATE())
      GROUP BY DATE_TRUNC('month', registration_date)
      ORDER BY month
```

---

## 4. Example: Sales Analytics Semantic View (Multi-Table)

### 4.1 Full YAML Definition

```yaml
# semantic/sv_pex_sales_analytics.yaml

name: sv_pex_sales_analytics

description: |
  Sales Analytics semantic view for revenue and order analysis.
  
  ## Purpose
  Comprehensive sales analysis combining order facts with customer and product 
  dimensions for revenue tracking, trend analysis, and business performance monitoring.
  
  ## Target Users
  - **Revenue Operations**: Track sales performance and targets
  - **Finance**: Revenue reporting and forecasting
  - **Product**: Product performance and mix analysis
  - **Executive Team**: Business health dashboards
  
  ## Key Metrics Available
  - Revenue (gross, net, by dimension)
  - Order counts and average order value
  - Product performance metrics
  - Customer purchase patterns
  
  ## Sample Questions
  - "What is total revenue by month?"
  - "Which products generate the most revenue?"
  - "What is the average order value by customer tier?"
  - "Show me daily sales for the last 30 days"

tables:
  - name: orders
    base_table:
      database: PEX_DB
      schema: METRICS
      table: fact_orders
    
    description: Order line item fact table with transactional data
    
    dimensions:
      - name: order_id
        expr: order_id
        description: Unique order identifier
        data_type: VARCHAR
        
      - name: order_number
        expr: order_number
        description: Business-facing order number
        data_type: VARCHAR
        
      - name: order_status
        expr: order_status
        description: Current status of the order
        data_type: VARCHAR
        
    measures:
      - name: order_count
        expr: COUNT(DISTINCT order_id)
        description: Number of unique orders
        data_type: INTEGER
        default_aggregation: COUNT_DISTINCT
        
      - name: line_count
        expr: COUNT(*)
        description: Number of order line items
        data_type: INTEGER
        default_aggregation: COUNT
        
      - name: total_revenue
        expr: SUM(line_amount)
        description: Total gross revenue
        data_type: DECIMAL
        default_aggregation: SUM
        
      - name: total_quantity
        expr: SUM(quantity)
        description: Total units sold
        data_type: INTEGER
        default_aggregation: SUM
        
      - name: avg_order_value
        expr: AVG(line_amount)
        description: Average order value
        data_type: DECIMAL
        default_aggregation: AVG
        
      - name: total_discount
        expr: SUM(discount_amount)
        description: Total discounts applied
        data_type: DECIMAL
        default_aggregation: SUM
        
      - name: total_tax
        expr: SUM(tax_amount)
        description: Total tax collected
        data_type: DECIMAL
        default_aggregation: SUM
        
      - name: total_margin
        expr: SUM(margin_amount)
        description: Total gross margin
        data_type: DECIMAL
        default_aggregation: SUM
        
      - name: avg_margin_pct
        expr: AVG(margin_pct)
        description: Average margin percentage
        data_type: DECIMAL
        default_aggregation: AVG
        
    time_dimensions:
      - name: order_date
        expr: order_date
        description: Date the order was placed
        
      - name: shipped_date
        expr: shipped_date
        description: Date the order was shipped
        
      - name: delivered_date
        expr: delivered_date
        description: Date the order was delivered

  - name: customers
    base_table:
      database: PEX_DB
      schema: METRICS
      table: dim_customer
    
    description: Customer dimension for order analysis
    
    dimensions:
      - name: customer_name
        expr: full_name
        description: Customer full name
        data_type: VARCHAR
        
      - name: customer_tier
        expr: customer_tier
        description: Customer value tier
        data_type: VARCHAR
        
      - name: lifecycle_stage
        expr: lifecycle_stage
        description: Customer lifecycle stage
        data_type: VARCHAR
        
      - name: customer_city
        expr: city
        description: Customer city
        data_type: VARCHAR
        
      - name: customer_state
        expr: state
        description: Customer state
        data_type: VARCHAR
        
      - name: customer_country
        expr: country
        description: Customer country
        data_type: VARCHAR

  - name: products
    base_table:
      database: PEX_DB
      schema: METRICS
      table: dim_product
    
    description: Product dimension for sales analysis
    
    dimensions:
      - name: product_name
        expr: product_name
        description: Product name
        data_type: VARCHAR
        
      - name: product_category
        expr: category
        description: Product category
        data_type: VARCHAR
        
      - name: product_subcategory
        expr: subcategory
        description: Product subcategory
        data_type: VARCHAR
        
      - name: brand
        expr: brand_name
        description: Product brand
        data_type: VARCHAR
        
      - name: product_tier
        expr: product_tier
        description: Product performance tier
        data_type: VARCHAR

  - name: dates
    base_table:
      database: PEX_DB
      schema: METRICS
      table: dim_date
    
    description: Date dimension for time-based analysis
    
    dimensions:
      - name: date
        expr: date_day
        description: Calendar date
        data_type: DATE
        
      - name: year
        expr: year
        description: Calendar year
        data_type: INTEGER
        
      - name: quarter
        expr: quarter
        description: Calendar quarter (1-4)
        data_type: INTEGER
        
      - name: month
        expr: month
        description: Calendar month (1-12)
        data_type: INTEGER
        
      - name: month_name
        expr: month_name
        description: Month name (January, February, etc.)
        data_type: VARCHAR
        
      - name: week_of_year
        expr: week_of_year
        description: Week number of the year
        data_type: INTEGER
        
      - name: day_of_week
        expr: day_name
        description: Day name (Monday, Tuesday, etc.)
        data_type: VARCHAR
        
      - name: fiscal_year
        expr: fiscal_year
        description: Fiscal year
        data_type: INTEGER
        
      - name: fiscal_quarter
        expr: fiscal_quarter
        description: Fiscal quarter (1-4)
        data_type: INTEGER
        
      - name: is_weekend
        expr: is_weekend
        description: Whether the date is a weekend
        data_type: BOOLEAN

joins:
  - name: order_customer
    left_table: orders
    right_table: customers
    join_type: left
    condition: "orders.customer_key = customers.customer_key AND customers.is_current = TRUE"
    
  - name: order_product
    left_table: orders
    right_table: products
    join_type: left
    condition: "orders.product_key = products.product_key AND products.is_current = TRUE"
    
  - name: order_date
    left_table: orders
    right_table: dates
    join_type: left
    condition: "orders.date_key = dates.date_key"

filters:
  - name: completed_orders
    expr: orders.order_status = 'COMPLETED'
    description: Only completed orders (excludes cancelled, pending)
    
  - name: current_year
    expr: dates.year = YEAR(CURRENT_DATE())
    description: Current calendar year only
    
  - name: current_fiscal_year
    expr: dates.fiscal_year = (CASE WHEN MONTH(CURRENT_DATE()) >= 7 THEN YEAR(CURRENT_DATE()) + 1 ELSE YEAR(CURRENT_DATE()) END)
    description: Current fiscal year only

verified_queries:
  - name: revenue_by_month
    question: "What is total revenue by month?"
    sql: |
      SELECT 
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT f.order_id) AS orders,
        ROUND(SUM(f.line_amount), 2) AS revenue
      FROM PEX_DB.METRICS.fact_orders f
      JOIN PEX_DB.METRICS.dim_date d ON f.date_key = d.date_key
      WHERE f.order_status = 'COMPLETED'
      GROUP BY d.year, d.month, d.month_name
      ORDER BY d.year DESC, d.month DESC
      LIMIT 24

  - name: revenue_by_product_category
    question: "Which product categories generate the most revenue?"
    sql: |
      SELECT 
        p.category AS product_category,
        COUNT(DISTINCT f.order_id) AS orders,
        SUM(f.quantity) AS units_sold,
        ROUND(SUM(f.line_amount), 2) AS revenue,
        ROUND(AVG(f.margin_pct), 2) AS avg_margin_pct
      FROM PEX_DB.METRICS.fact_orders f
      JOIN PEX_DB.METRICS.dim_product p ON f.product_key = p.product_key
      WHERE f.order_status = 'COMPLETED'
        AND p.is_current = TRUE
      GROUP BY p.category
      ORDER BY revenue DESC

  - name: aov_by_customer_tier
    question: "What is the average order value by customer tier?"
    sql: |
      SELECT 
        c.customer_tier,
        COUNT(DISTINCT f.order_id) AS orders,
        COUNT(DISTINCT c.customer_id) AS customers,
        ROUND(SUM(f.line_amount), 2) AS revenue,
        ROUND(SUM(f.line_amount) / COUNT(DISTINCT f.order_id), 2) AS avg_order_value
      FROM PEX_DB.METRICS.fact_orders f
      JOIN PEX_DB.METRICS.dim_customer c ON f.customer_key = c.customer_key
      WHERE f.order_status = 'COMPLETED'
        AND c.is_current = TRUE
      GROUP BY c.customer_tier
      ORDER BY 
        CASE c.customer_tier 
          WHEN 'PLATINUM' THEN 1 
          WHEN 'GOLD' THEN 2 
          WHEN 'SILVER' THEN 3 
          ELSE 4 
        END

  - name: daily_sales_last_30_days
    question: "Show me daily sales for the last 30 days"
    sql: |
      SELECT 
        d.date_day AS date,
        d.day_name AS day_of_week,
        COUNT(DISTINCT f.order_id) AS orders,
        ROUND(SUM(f.line_amount), 2) AS revenue
      FROM PEX_DB.METRICS.fact_orders f
      JOIN PEX_DB.METRICS.dim_date d ON f.date_key = d.date_key
      WHERE f.order_status = 'COMPLETED'
        AND d.date_day >= DATEADD('day', -30, CURRENT_DATE())
        AND d.date_day < CURRENT_DATE()
      GROUP BY d.date_day, d.day_name
      ORDER BY d.date_day DESC
```

---

## 5. Semantic View Best Practices

### 5.1 Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Semantic View | `sv_{domain}_{subject}` | `sv_pex_customer_analytics` |
| Table Alias | Singular noun | `customers`, `orders`, `products` |
| Dimension | Business name, no prefix | `customer_tier`, `product_category` |
| Measure | Descriptive with aggregation hint | `total_revenue`, `avg_order_value` |
| Time Dimension | `{event}_date` | `order_date`, `registration_date` |
| Filter | Descriptive condition | `active_customers`, `completed_orders` |

### 5.2 Description Guidelines

- **Semantic View Description**: Include purpose, target users, key metrics, sample questions
- **Table Description**: Explain what the table contains and its grain
- **Dimension Description**: Business definition, valid values if categorical
- **Measure Description**: What it calculates, aggregation method, currency if applicable
- **Filter Description**: When to use it, what it excludes

### 5.3 Measure Design

| Aggregation | Use When | Example |
|-------------|----------|---------|
| SUM | Additive metrics | `SUM(revenue)` |
| COUNT | Counting occurrences | `COUNT(*)` |
| COUNT DISTINCT | Counting unique values | `COUNT(DISTINCT customer_id)` |
| AVG | Average values | `AVG(order_amount)` |
| MIN/MAX | Extreme values | `MIN(order_date)` |

### 5.4 Join Best Practices

- Always specify `is_current = TRUE` for SCD2 dimensions
- Use LEFT JOIN to preserve fact rows even without dimension match
- Document join conditions clearly
- Keep join conditions simple (equality on keys)

### 5.5 Verified Query Guidelines

- Cover the most common questions for the semantic view
- Use clear, natural language for the question
- Include proper formatting and rounding in SQL
- Order results logically (by value, date, or category order)
- Limit large result sets
