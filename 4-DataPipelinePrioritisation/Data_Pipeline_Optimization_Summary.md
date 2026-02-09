# Data Pipeline Optimization Initiative - Summary Document

**Prepared for:** Snowflake Professional Services Engagement  
**Date:** February 2, 2026  
**Initiative:** Data Pipeline Prioritization for Snowflake

---

## 1. Executive Summary

Canva is seeking Snowflake Professional Services support to migrate and optimize data pipelines across multiple domains as part of their 2026 "AI-Ready Data" company goal. The engagement involves migrating transformation pipelines from a monolithic dbt project to domain-specific data services architecture.

---

## 2. What the Customer is Looking For

Based on the email thread between Adrian Jacobs (Canva) and Vanessa Barcellona (Snowflake):

### Primary Objectives:
1. **Assistance with data asset migration** - Stack-ranked list of pipelines requiring migration support
2. **Outcomes-based deliverables** - Clear, measurable deliverables with cost proposals per line item
3. **Phase 1 scoping** - Initial proposal covering deliverables, effort, and timeline
4. **Potential partner support** if needed for scale

### Key Deliverables Expected:
- Cost proposals per pipeline/data asset
- Scoping workshop for deeper requirement gathering
- Phase 1 proposal with concrete deliverables

---

## 3. Scope Analysis: DBT Migration vs. Storage Layer Federation

### Answer: BOTH - DBT Pipeline Migration AND Storage Layer Restructuring

| Component | In Scope | Details |
|-----------|----------|---------|
| **DBT Project Migration** | YES | Moving dbt models from monolithic "Transform" project to domain-specific dbt projects |
| **Schema Redesign** | YES | New schema architecture within domain data services |
| **Storage Layer Federation** | YES | Moving data from centralized schemas to domain-owned Snowflake schemas |
| **Semantic Layer Creation** | YES | Building semantic views for Snowflake Intelligence agent consumption |

### Evidence from Documents:

**From Monetisation Domain Migration PDF:**
> "The purpose of this migration is to decouple data models from the mono repo and orchestrate domain data in its own space, with the opportunity to redesign and refactor our existing models to adapt to the AI & LLM consumption."

**From Product Experience HLDD:**
> "Though we are migrating entity and metric pipelines from the current transform namespace over to Data Services Architecture, this exercise is not intended to be a lift and shift of these models. Rather, this is an opportunity to re-imagine our entities, models and data flows."

---

## 4. Detailed Scope by Domain

### 4.1 Monetisation Domain (Owner: Kaihao Wang, Aiden Guerin)

**Current State:**
- All models in `data-warehouse` GitHub repository
- Single dbt project ("Transform") with 5000+ models
- Cron job in k8s orchestrating entire project

**Migration Scope:**
| Report Pipeline | Key Tables |
|-----------------|------------|
| Merchant Fee/Transaction | gateway_transaction_summary_by_date, gateway_fees_summary_by_date |
| Payout | payout_brand_earnings_by_month, payout_payment_by_date, developer_portal_premium_app_payouts, revenue_cash_rec_payout_report |
| Coupon & Offer | coupon_subscriptions_and_activity_member, fact_subscription_coupon_redemption, fact_subscription_offer_redemption |
| Refund & Dispute | fact_refund, fact_refund_enriched, dispute_summary_by_date, dispute_scheme_monitoring_by_date, dispute_scheme_monitoring_alerts |

**Requirements:**
- Full historic data migration
- Schema redesign
- Migration instructions for downstream consumers
- Performance, data quality, compliance validation

---

### 4.2 Product Experience Domain (Owner: Owen Yan)

**Architecture:**
- **Conformed Layer** - Reusable event-level facts and entity models
- **Metrics Layer** - Star schema dimensional models
- **Semantic Layer** - Governed AI-ready interface via Snowflake Intelligence

**Phase 1 Scope:**
| Layer | Models | Notes |
|-------|--------|-------|
| Conformed Layer | User Feature Interactions, Editor Sessions, Design Lifecycle, AI Platform, Education entities, Brand System entities | Event-level facts |
| Metrics Layer | Product Adoption DAU/MAU, Engagement metrics, Retention curves, Cost & Operations | Star schema |
| Semantic Layer | Semantic views for conversational AI | Snowflake Intelligence integration |

**Estimated Model Count:** ~145 models (82 incremental/insert)

**External Dependencies:**
- Foundation domain (user, date, platform, brand, subscription)
- Growth domain (subscriptions, activations, signups)
- Content & Discovery domain
- Sales & Success domain
- Ecosystem domain
- And 6+ other domains

---

## 5. Technical Complexity Factors

| Factor | Impact |
|--------|--------|
| **Cross-domain dependencies** | High - Multiple domains feed into Product Experience |
| **Model refactoring** | Medium-High - Not lift-and-shift; requires redesign |
| **Orchestration redesign** | Medium - Moving from single Cron to event-based triggers |
| **Semantic layer creation** | New capability - Requires AI-readiness design |
| **Historic data migration** | High - Full historical data required |
| **Consumer migration** | Medium - Downstream consumers need migration guides |

---

## 6. Questions for Stakeholder Calls

### 6.1 Questions for Monetisation Domain (Aiden Guerin, Kaihao Wang)

**Scope Clarification:**
1. How many upstream dependencies exist for each of the 4 report pipelines? Are they all within the Monetisation domain or cross-domain?
2. What is the current data volume (row counts, storage size) for each key table?
3. Are there existing metric definitions documented, or do they need to be created from scratch for the semantic layer?

**Technical Questions:**
4. What is the current refresh frequency for each pipeline (daily, hourly, near-real-time)?
5. Are there any existing data quality tests or validation rules that need to be migrated?
6. What compliance/audit requirements apply to financial reporting tables (Merchant Fee, Payout)?

**Migration Logistics:**
7. Is there a parallel-run period expected where both old and new pipelines coexist?
8. Who are the primary downstream consumers, and what is the communication plan for migration?
9. What is the acceptable downtime or data latency during migration?

**Effort Estimation:**
10. Are the dbt models standard SQL transformations, or do they include complex macros/custom code?
11. What level of schema redesign is expected - minor column changes or fundamental restructuring?
12. Is there existing documentation on the Transform project models, or will reverse engineering be required?

---

### 6.2 Questions for Product Experience Domain (Owen Yan)

**Scope Clarification:**
1. Of the 145 models estimated for migration, how many are critical path for the Phase 1 Key Metrics pipelines?
2. What is the priority order among the 6 Conformed Layer entity groups (User Interactions, Editor Sessions, Design Lifecycle, AI Platform, Evaluations, Education)?
3. Which external domain dependencies are blockers vs. can proceed in parallel?

**Architecture Questions:**
4. Is the event-based orchestration infrastructure (triggers) already in place, or does it need to be built?
5. What Snowflake features are currently in use (Dynamic Tables, Streams, Tasks) vs. planned for the new architecture?
6. How will the Semantic Layer integrate with existing BI tools (Mode, Looker, etc.)?

**Data Volume & Performance:**
7. What are the largest fact tables by row count and storage?
8. What are the current query performance SLAs for reporting?
9. Are there specific tables with performance issues that need optimization during migration?

**AI-Readiness:**
10. What specific requirements exist for "AI-Ready Data" that impact the model design?
11. Is there an existing Snowflake Intelligence deployment, or is this net-new?
12. What metadata/documentation standards are required for the semantic layer?

**Cross-Domain Coordination:**
13. What is the expected timeline for Foundation Conformed Layer completion (critical dependency)?
14. Who owns the cross-domain data contracts, and are they documented?

---

## 7. Key Risks and Assumptions

### Risks:
1. **Cross-domain dependencies** may cause delays if upstream domains aren't ready
2. **Scope creep** - "Re-imagining" models vs. migration could expand effort
3. **Consumer impact** - Downstream users may require significant change management
4. **Compliance requirements** - Financial data may have audit/regulatory constraints

### Assumptions:
1. Snowflake environment and access is already provisioned
2. Canva team retains domain knowledge for business logic
3. Phase 1 timeline aligns with company 2026 AI-Ready Data goal
4. Testing environments available for parallel runs

---

## 8. Recommended Next Steps

1. **Schedule 30-minute calls** with Aiden Guerin/Kaihao Wang (Monetisation) and Owen Yan (Product Experience)
2. **Request access** to existing dbt project and model documentation
3. **Obtain Snowflake access** to assess current data volumes and performance baselines
4. **Clarify Phase 1 boundaries** before developing cost estimates

---

*Document prepared by Snowflake Professional Services*
