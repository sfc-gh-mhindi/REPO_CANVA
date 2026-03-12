-- ============================================================================
-- POORLY MODELED SOURCE TABLES FOR DBT REFACTORING SKILL TEST
-- These tables intentionally violate normalization principles and contain:
-- - Redundant data across tables
-- - Denormalized structures
-- - Inconsistent naming
-- - Mixed granularities
-- - No proper foreign keys
-- ============================================================================

CREATE OR REPLACE DATABASE DBT_REFACTOR_TEST;
CREATE OR REPLACE SCHEMA DBT_REFACTOR_TEST.RAW;

-- ============================================================================
-- TABLE 1: raw_orders - Massively denormalized order table
-- Contains customer, product, shipping, and payment info all in one
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_ORDERS (
    order_id VARCHAR(50),
    order_date TIMESTAMP,
    order_status VARCHAR(20),
    order_total DECIMAL(18,2),
    order_tax DECIMAL(18,2),
    order_shipping_cost DECIMAL(18,2),
    order_discount DECIMAL(18,2),
    order_currency VARCHAR(3),
    -- Customer info embedded (violates 1NF)
    customer_id VARCHAR(50),
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_email VARCHAR(200),
    customer_phone VARCHAR(50),
    customer_created_date DATE,
    customer_tier VARCHAR(20),
    customer_lifetime_value DECIMAL(18,2),
    -- Billing address embedded
    billing_address_line1 VARCHAR(200),
    billing_address_line2 VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(50),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(50),
    -- Shipping address embedded
    shipping_address_line1 VARCHAR(200),
    shipping_address_line2 VARCHAR(200),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(50),
    -- Product info embedded (should be separate line items)
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    product_sku VARCHAR(50),
    product_category VARCHAR(100),
    product_subcategory VARCHAR(100),
    product_brand VARCHAR(100),
    product_unit_price DECIMAL(18,2),
    quantity_ordered INT,
    -- Payment info embedded
    payment_method VARCHAR(50),
    payment_card_type VARCHAR(20),
    payment_card_last_four VARCHAR(4),
    payment_status VARCHAR(20),
    payment_date TIMESTAMP,
    -- Shipping info embedded
    shipping_carrier VARCHAR(50),
    shipping_method VARCHAR(50),
    shipping_tracking_number VARCHAR(100),
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    -- Sales rep info embedded
    sales_rep_id VARCHAR(50),
    sales_rep_name VARCHAR(100),
    sales_rep_region VARCHAR(50),
    sales_rep_commission_rate DECIMAL(5,2),
    -- Audit fields
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    source_system VARCHAR(50)
);

-- ============================================================================
-- TABLE 2: raw_transactions - Overlaps significantly with orders
-- Different structure, same conceptual data
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_TRANSACTIONS (
    txn_id VARCHAR(50),
    txn_timestamp TIMESTAMP,
    txn_type VARCHAR(20), -- SALE, REFUND, VOID
    txn_amount DECIMAL(18,2),
    txn_tax_amount DECIMAL(18,2),
    txn_fee DECIMAL(18,2),
    txn_net DECIMAL(18,2),
    txn_currency_code VARCHAR(3),
    -- Order reference
    related_order_id VARCHAR(50),
    -- Customer info (duplicated from orders)
    cust_id VARCHAR(50),
    cust_name VARCHAR(200),
    cust_email_address VARCHAR(200),
    cust_phone_number VARCHAR(50),
    cust_segment VARCHAR(50),
    -- Product info (duplicated)
    prod_id VARCHAR(50),
    prod_description VARCHAR(200),
    prod_category_name VARCHAR(100),
    prod_unit_cost DECIMAL(18,2),
    prod_qty INT,
    -- Payment details
    pay_method VARCHAR(50),
    pay_processor VARCHAR(50),
    pay_auth_code VARCHAR(50),
    pay_reference VARCHAR(100),
    -- Store/channel info
    store_id VARCHAR(50),
    store_name VARCHAR(100),
    store_location VARCHAR(200),
    channel_type VARCHAR(50), -- ONLINE, IN_STORE, MOBILE
    -- Timestamps
    created_timestamp TIMESTAMP,
    modified_timestamp TIMESTAMP
);

-- ============================================================================
-- TABLE 3: raw_customers_v1 - First customer table (legacy system)
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V1 (
    cust_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    dob DATE,
    gender VARCHAR(10),
    registration_date DATE,
    last_login_date TIMESTAMP,
    account_status VARCHAR(20),
    -- Address (only one, no history)
    address1 VARCHAR(200),
    address2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    country VARCHAR(50),
    -- Preferences embedded as delimited string (terrible pattern)
    marketing_preferences VARCHAR(500), -- 'email,sms,push'
    product_preferences VARCHAR(500),   -- 'electronics,clothing'
    -- Computed fields stored (should be calculated)
    total_orders INT,
    total_spend DECIMAL(18,2),
    avg_order_value DECIMAL(18,2),
    last_order_date DATE,
    days_since_last_order INT,
    customer_score DECIMAL(5,2),
    -- Source tracking
    acquisition_source VARCHAR(50),
    acquisition_campaign VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ============================================================================
-- TABLE 4: raw_customers_v2 - Second customer table (new system)
-- Different structure, overlapping data
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_CUSTOMERS_V2 (
    customer_key VARCHAR(50),
    customer_external_id VARCHAR(50),
    name_first VARCHAR(100),
    name_last VARCHAR(100),
    name_full VARCHAR(200),
    email_primary VARCHAR(200),
    email_secondary VARCHAR(200),
    phone_mobile VARCHAR(50),
    phone_home VARCHAR(50),
    phone_work VARCHAR(50),
    date_of_birth DATE,
    gender_code VARCHAR(5),
    -- Multiple addresses as JSON (mixed approach)
    addresses_json VARIANT,
    -- Loyalty info embedded
    loyalty_program_id VARCHAR(50),
    loyalty_tier VARCHAR(20),
    loyalty_points_balance INT,
    loyalty_points_lifetime INT,
    loyalty_enrollment_date DATE,
    -- Subscription info embedded
    subscription_status VARCHAR(20),
    subscription_plan VARCHAR(50),
    subscription_start_date DATE,
    subscription_end_date DATE,
    subscription_monthly_fee DECIMAL(18,2),
    -- Risk/fraud flags
    fraud_risk_score DECIMAL(5,2),
    account_locked BOOLEAN,
    verification_status VARCHAR(20),
    -- Timestamps
    sys_created_ts TIMESTAMP,
    sys_updated_ts TIMESTAMP,
    sys_source VARCHAR(50)
);

-- ============================================================================
-- TABLE 5: raw_products_flat - Denormalized product catalog
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_PRODUCTS_FLAT (
    product_id VARCHAR(50),
    sku VARCHAR(50),
    upc VARCHAR(20),
    product_name VARCHAR(200),
    product_description TEXT,
    product_short_desc VARCHAR(500),
    -- Category hierarchy flattened
    category_l1_id VARCHAR(50),
    category_l1_name VARCHAR(100),
    category_l2_id VARCHAR(50),
    category_l2_name VARCHAR(100),
    category_l3_id VARCHAR(50),
    category_l3_name VARCHAR(100),
    -- Brand info embedded
    brand_id VARCHAR(50),
    brand_name VARCHAR(100),
    brand_country_of_origin VARCHAR(50),
    brand_parent_company VARCHAR(100),
    -- Supplier info embedded
    supplier_id VARCHAR(50),
    supplier_name VARCHAR(200),
    supplier_contact_email VARCHAR(200),
    supplier_lead_time_days INT,
    supplier_minimum_order_qty INT,
    -- Pricing (multiple prices in same row - bad)
    cost_price DECIMAL(18,2),
    wholesale_price DECIMAL(18,2),
    retail_price DECIMAL(18,2),
    sale_price DECIMAL(18,2),
    member_price DECIMAL(18,2),
    -- Inventory info (should be separate)
    current_stock_qty INT,
    reorder_point INT,
    reorder_qty INT,
    warehouse_location VARCHAR(50),
    -- Product attributes as separate columns (should be EAV or JSON)
    attr_color VARCHAR(50),
    attr_size VARCHAR(20),
    attr_weight DECIMAL(10,2),
    attr_weight_unit VARCHAR(10),
    attr_dimensions VARCHAR(50),
    attr_material VARCHAR(100),
    -- Flags
    is_active BOOLEAN,
    is_featured BOOLEAN,
    is_clearance BOOLEAN,
    is_new_arrival BOOLEAN,
    -- Timestamps
    created_date TIMESTAMP,
    modified_date TIMESTAMP,
    discontinued_date DATE
);

-- ============================================================================
-- TABLE 6: raw_inventory_log - Inventory movements with product info repeated
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_INVENTORY_LOG (
    log_id VARCHAR(50),
    log_timestamp TIMESTAMP,
    movement_type VARCHAR(20), -- RECEIPT, SALE, ADJUSTMENT, RETURN, TRANSFER
    quantity_change INT,
    quantity_before INT,
    quantity_after INT,
    -- Product info repeated every row
    product_id VARCHAR(50),
    product_sku VARCHAR(50),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    -- Warehouse info repeated
    warehouse_id VARCHAR(50),
    warehouse_name VARCHAR(100),
    warehouse_city VARCHAR(100),
    warehouse_state VARCHAR(50),
    warehouse_country VARCHAR(50),
    warehouse_capacity INT,
    -- Reference info
    reference_type VARCHAR(50), -- ORDER, PO, ADJUSTMENT_TICKET
    reference_id VARCHAR(50),
    -- User who made change
    user_id VARCHAR(50),
    user_name VARCHAR(100),
    user_department VARCHAR(50),
    -- Cost info
    unit_cost DECIMAL(18,2),
    total_cost DECIMAL(18,2),
    -- Notes
    notes TEXT,
    created_at TIMESTAMP
);

-- ============================================================================
-- TABLE 7: raw_shipping_events - Shipping events with redundant info
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_SHIPPING_EVENTS (
    event_id VARCHAR(50),
    event_timestamp TIMESTAMP,
    event_type VARCHAR(50), -- LABEL_CREATED, PICKED_UP, IN_TRANSIT, OUT_FOR_DELIVERY, DELIVERED, EXCEPTION
    event_description VARCHAR(500),
    -- Order info repeated
    order_id VARCHAR(50),
    order_date DATE,
    order_total DECIMAL(18,2),
    -- Customer info repeated
    customer_id VARCHAR(50),
    customer_name VARCHAR(200),
    customer_email VARCHAR(200),
    customer_phone VARCHAR(50),
    -- Shipping address repeated every event
    ship_to_name VARCHAR(200),
    ship_to_address1 VARCHAR(200),
    ship_to_address2 VARCHAR(200),
    ship_to_city VARCHAR(100),
    ship_to_state VARCHAR(50),
    ship_to_postal VARCHAR(20),
    ship_to_country VARCHAR(50),
    -- Carrier info
    carrier_code VARCHAR(20),
    carrier_name VARCHAR(100),
    service_type VARCHAR(50),
    tracking_number VARCHAR(100),
    -- Package info
    package_weight DECIMAL(10,2),
    package_dimensions VARCHAR(50),
    package_count INT,
    -- Location info (for in-transit events)
    event_location_city VARCHAR(100),
    event_location_state VARCHAR(50),
    event_location_country VARCHAR(50),
    -- Cost info
    shipping_cost DECIMAL(18,2),
    insurance_cost DECIMAL(18,2),
    -- Timestamps
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    created_at TIMESTAMP
);

-- ============================================================================
-- TABLE 8: raw_returns - Returns with all related info embedded
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_RETURNS (
    return_id VARCHAR(50),
    return_date TIMESTAMP,
    return_status VARCHAR(20), -- REQUESTED, APPROVED, RECEIVED, REFUNDED, DENIED
    return_reason VARCHAR(100),
    return_notes TEXT,
    -- Original order info
    original_order_id VARCHAR(50),
    original_order_date DATE,
    original_order_total DECIMAL(18,2),
    -- Customer info repeated
    customer_id VARCHAR(50),
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_email VARCHAR(200),
    customer_phone VARCHAR(50),
    customer_tier VARCHAR(20),
    -- Product info repeated
    product_id VARCHAR(50),
    product_sku VARCHAR(50),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    product_unit_price DECIMAL(18,2),
    quantity_returned INT,
    -- Refund info
    refund_amount DECIMAL(18,2),
    refund_method VARCHAR(50),
    refund_status VARCHAR(20),
    refund_date TIMESTAMP,
    refund_transaction_id VARCHAR(50),
    -- Return shipping info
    return_carrier VARCHAR(50),
    return_tracking_number VARCHAR(100),
    return_received_date DATE,
    -- Inspection info
    inspection_status VARCHAR(20),
    inspection_notes TEXT,
    restockable BOOLEAN,
    -- Processing info
    processed_by_user_id VARCHAR(50),
    processed_by_user_name VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ============================================================================
-- TABLE 9: raw_marketing_campaigns - Campaigns with embedded segments
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_MARKETING_CAMPAIGNS (
    campaign_id VARCHAR(50),
    campaign_name VARCHAR(200),
    campaign_type VARCHAR(50), -- EMAIL, SMS, PUSH, SOCIAL, DISPLAY
    campaign_status VARCHAR(20),
    campaign_objective VARCHAR(100),
    -- Dates
    start_date DATE,
    end_date DATE,
    created_date TIMESTAMP,
    -- Budget info
    budget_amount DECIMAL(18,2),
    budget_spent DECIMAL(18,2),
    budget_currency VARCHAR(3),
    -- Target segment info embedded (should be separate)
    target_segment_id VARCHAR(50),
    target_segment_name VARCHAR(100),
    target_segment_criteria TEXT, -- JSON-like text with criteria
    target_audience_size INT,
    -- Channel details embedded
    channel_id VARCHAR(50),
    channel_name VARCHAR(100),
    channel_platform VARCHAR(50),
    -- Performance metrics embedded (should be in separate fact table)
    impressions INT,
    clicks INT,
    click_rate DECIMAL(10,4),
    conversions INT,
    conversion_rate DECIMAL(10,4),
    revenue_attributed DECIMAL(18,2),
    cost_per_click DECIMAL(18,4),
    cost_per_conversion DECIMAL(18,4),
    return_on_ad_spend DECIMAL(10,4),
    -- Creative info embedded
    creative_id VARCHAR(50),
    creative_name VARCHAR(200),
    creative_type VARCHAR(50),
    creative_url VARCHAR(500),
    -- Approval info
    approved_by_user_id VARCHAR(50),
    approved_by_user_name VARCHAR(100),
    approval_date TIMESTAMP,
    -- Source
    created_by_user_id VARCHAR(50),
    created_by_user_name VARCHAR(100),
    updated_at TIMESTAMP
);

-- ============================================================================
-- TABLE 10: raw_clickstream - Web events with repeated context
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_CLICKSTREAM (
    event_id VARCHAR(100),
    event_timestamp TIMESTAMP,
    event_type VARCHAR(50), -- PAGE_VIEW, CLICK, SCROLL, FORM_SUBMIT, ADD_TO_CART, CHECKOUT_START
    event_name VARCHAR(100),
    -- Session info repeated every event
    session_id VARCHAR(100),
    session_start_time TIMESTAMP,
    session_duration_seconds INT,
    session_page_views INT,
    session_events_count INT,
    -- User info repeated
    user_id VARCHAR(50),
    user_anonymous_id VARCHAR(100),
    user_email VARCHAR(200),
    user_tier VARCHAR(20),
    is_logged_in BOOLEAN,
    -- Device info repeated
    device_type VARCHAR(20),
    device_os VARCHAR(50),
    device_browser VARCHAR(50),
    device_screen_resolution VARCHAR(20),
    -- Location info repeated
    geo_country VARCHAR(50),
    geo_region VARCHAR(50),
    geo_city VARCHAR(100),
    geo_postal_code VARCHAR(20),
    ip_address VARCHAR(50),
    -- Page info
    page_url VARCHAR(1000),
    page_path VARCHAR(500),
    page_title VARCHAR(200),
    page_referrer VARCHAR(1000),
    -- UTM params repeated
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_term VARCHAR(100),
    utm_content VARCHAR(100),
    -- Product context (if applicable)
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    product_price DECIMAL(18,2),
    -- Cart context
    cart_id VARCHAR(50),
    cart_total DECIMAL(18,2),
    cart_item_count INT,
    -- Custom properties as JSON
    custom_properties VARIANT,
    -- Processing metadata
    processed_at TIMESTAMP,
    batch_id VARCHAR(50)
);

-- ============================================================================
-- TABLE 11: raw_support_tickets - Support tickets with embedded info
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_SUPPORT_TICKETS (
    ticket_id VARCHAR(50),
    ticket_number VARCHAR(20),
    ticket_subject VARCHAR(500),
    ticket_description TEXT,
    ticket_status VARCHAR(20), -- OPEN, IN_PROGRESS, PENDING, RESOLVED, CLOSED
    ticket_priority VARCHAR(20), -- LOW, MEDIUM, HIGH, URGENT
    ticket_type VARCHAR(50), -- QUESTION, PROBLEM, FEATURE_REQUEST, COMPLAINT
    -- Customer info repeated
    customer_id VARCHAR(50),
    customer_name VARCHAR(200),
    customer_email VARCHAR(200),
    customer_phone VARCHAR(50),
    customer_tier VARCHAR(20),
    customer_company VARCHAR(200),
    -- Order context (if applicable)
    related_order_id VARCHAR(50),
    related_order_date DATE,
    related_order_total DECIMAL(18,2),
    -- Product context (if applicable)
    related_product_id VARCHAR(50),
    related_product_name VARCHAR(200),
    related_product_sku VARCHAR(50),
    -- Assignment info
    assigned_to_user_id VARCHAR(50),
    assigned_to_user_name VARCHAR(100),
    assigned_to_team VARCHAR(50),
    escalation_level INT,
    -- Timestamps
    created_at TIMESTAMP,
    first_response_at TIMESTAMP,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    -- SLA info embedded
    sla_policy_id VARCHAR(50),
    sla_policy_name VARCHAR(100),
    sla_first_response_target_hours INT,
    sla_resolution_target_hours INT,
    sla_first_response_breached BOOLEAN,
    sla_resolution_breached BOOLEAN,
    -- Satisfaction info
    satisfaction_rating INT,
    satisfaction_comment TEXT,
    -- Channel info
    channel VARCHAR(50), -- EMAIL, PHONE, CHAT, SOCIAL
    source VARCHAR(50),
    -- Tags as delimited string
    tags VARCHAR(500),
    updated_at TIMESTAMP
);

-- ============================================================================
-- TABLE 12: raw_employee_sales - Sales by employee with redundant info
-- ============================================================================
CREATE OR REPLACE TABLE DBT_REFACTOR_TEST.RAW.RAW_EMPLOYEE_SALES (
    record_id VARCHAR(50),
    sale_date DATE,
    sale_timestamp TIMESTAMP,
    -- Employee info repeated
    employee_id VARCHAR(50),
    employee_first_name VARCHAR(100),
    employee_last_name VARCHAR(100),
    employee_email VARCHAR(200),
    employee_department VARCHAR(50),
    employee_title VARCHAR(100),
    employee_hire_date DATE,
    employee_manager_id VARCHAR(50),
    employee_manager_name VARCHAR(200),
    -- Store/location info repeated
    store_id VARCHAR(50),
    store_name VARCHAR(100),
    store_address VARCHAR(200),
    store_city VARCHAR(100),
    store_state VARCHAR(50),
    store_region VARCHAR(50),
    store_district VARCHAR(50),
    -- Sale details
    order_id VARCHAR(50),
    order_total DECIMAL(18,2),
    order_items_count INT,
    -- Commission calculation embedded (should be calculated)
    base_commission_rate DECIMAL(5,2),
    bonus_rate DECIMAL(5,2),
    commission_amount DECIMAL(18,2),
    -- Quota info embedded
    monthly_quota DECIMAL(18,2),
    quarterly_quota DECIMAL(18,2),
    annual_quota DECIMAL(18,2),
    mtd_sales DECIMAL(18,2),
    qtd_sales DECIMAL(18,2),
    ytd_sales DECIMAL(18,2),
    quota_attainment_pct DECIMAL(10,2),
    -- Performance tier
    performance_tier VARCHAR(20),
    performance_rank INT,
    created_at TIMESTAMP
);
