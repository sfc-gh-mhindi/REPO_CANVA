# Canva Data Migration Initiative
## Executive Presentation Summary

**Client:** Canva  
**Prepared by:** Snowflake Professional Services  
**Date:** February 2026  
**Document Status:** For Executive Review

---

## Portfolio Overview

| Domain | Total Effort (Days) | Investment (AUD) | Investment (USD) | Recommendation |
|--------|---------------------|------------------|------------------|----------------|
| **Monetisation - Subscriptions** | 189 | $613,534 | $390,821 | ✅ Execute |
| **Product Experience - dim_editor_session** | 30 | $99,428 | $63,336 | ✅ Execute |
| **Product Experience - Macros** | 71 | $262,313 | $167,093 | ✅ Execute |
| **Marketing Domain** | 37 | $118,569 | $75,528 | ✅ Execute |
| **Print Domain** | 68 | $221,558 | $141,133 | ✅ Execute |
| **Monetisation Domain** | 102 | $322,487 | $205,424 | ✅ Execute |
| **Pilot (Feature Catalog)** | 22 | $71,673 | $45,656 | ✅ Execute |
| **IT Domain (JIRA Analytics)** | 130 | $384,348 | $244,830 | ✅ Execute |
| **GRAND TOTAL** | **649** | **$2,093,910** | **$1,333,821** | |

*Exchange rate: 1 AUD = 0.637 USD | Daily rate: $3,224 AUD | AI-enhanced estimates (30% reduction on scalable activities)*

---

# Domain 1: Monetisation - Subscriptions

## 1. Scope
- Analyse ~250 existing DBT models with significant overlap/duplication
- Redesign into three-layer architecture with target 30% model reduction
- Consolidate ~30 end-user tables into streamlined reporting structure
- Create 7 semantic views for Snowflake Intelligence natural language queries
- Configure daily Airflow orchestration for automated refresh

## 2. Migration
- **Existing:** ~250 DBT models with significant duplication, ~30 end-user tables
- **Migration Work:**
  - Create 3 Snowflake databases (subscriptions_conformed, _metrics, _semantic)
  - Full analysis and lineage documentation of all 250 models
  - Model consolidation and reduction to ~175 models (30% reduction)
  - Create 7 semantic views (Revenue, Lifecycle, Churn, Conversion, Plan, Cohort, Billing)
  - Configure daily Airflow orchestration

## 3. New
- None (all work relates to migrating/restructuring existing pipelines)

## 4. Outcomes
Canva will receive:
- ✅ Consolidated subscription data platform with ~175 DBT models (30% reduction) eliminating duplication
- ✅ 7 semantic views enabling natural language queries for revenue, churn, conversion, and cohort analytics
- ✅ Three-layer architecture with complete documentation and migration guide

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 165 |
| Contingency (15%) | 25 |
| **Grand Total** | **189** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $613,534 |
| **USD** | $390,821 |

## 7. Assumptions
- 70% simple / 30% complex model distribution confirmed by domain owner
- Significant model overlap exists and can be consolidated
- No data migration required (rebuild approach)
- Upstream dependencies sourced directly from original domains
- Design approval cycles may extend timeline

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Gathering | Discovery | 3.0 | 2% |
| End-User Table Analysis | Analysis | 15.3 | 9% |
| DBT Model Analysis (Simple) | Analysis | 19.1 | 12% |
| DBT Model Analysis (Complex) | Analysis | 15.6 | 9% |
| Lineage Documentation | Analysis | 6.3 | 4% |
| Target Model Design | Design | 23.6 | 14% |
| Physical Layer Setup | Build | 1.0 | 1% |
| DBT Model Build (Simple) | Build | 21.6 | 13% |
| DBT Model Build (Complex) | Build | 27.3 | 17% |
| Semantic Layer | Build | 13.2 | 8% |
| Orchestration Setup | Build | 4.1 | 2% |
| Testing | Testing | 11.0 | 7% |
| Documentation | Documentation | 7.9 | 5% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 3.0 | 2% |
| Analysis | 56.3 | 34% |
| Design | 23.6 | 14% |
| Build | 67.2 | 41% |
| Testing | 11.0 | 7% |
| Documentation | 7.9 | 5% |

**Key Insight:** Analysis (34%) is significant due to the scale (250 DBT models + 30 end-user tables) and the need to identify consolidation opportunities. Build (41%) reflects the substantial reconstruction effort. Design (14%) is substantial to define the target state for ~175 consolidated models.

## 9. Recommendation
**✅ EXECUTE** - Largest and most complex domain with highest strategic value. Subscription analytics are critical to Canva's business. Model consolidation will significantly reduce technical debt.

---

# Domain 2: Product Experience - dim_editor_session

## 1. Scope
- Analyse and redesign monolithic dim_editor_session table into proper star schema
- Rebuild 7 DBT models into three-layer architecture
- Separate dimensional attributes (user, device, design, platform) from session facts
- Create semantic view for Editor Session analytics
- Configure daily Airflow orchestration

## 2. Migration
- **Existing:** 1 monolithic dimension table with mixed facts/dimensions, 7 DBT models
- **Migration Work:**
  - Create 3 Snowflake databases (product_experience_conformed, _metrics, _semantic)
  - Analyse and restructure 7 DBT models into ~5-7 grain-appropriate dimension and fact tables
  - Create 1 semantic view for Editor Session analytics
  - Configure daily scheduled Airflow orchestration
- No historical data migration required (rebuild from source)

## 3. New
- None (all work relates to restructuring existing pipeline)

## 4. Outcomes
Canva will receive:
- ✅ Proper star schema with separated dimensional attributes (user, device, design, platform) and session facts
- ✅ Semantic view enabling natural language queries with daily automated refresh via Airflow
- ✅ Complete documentation and migration guide for downstream consumers

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 26 |
| Contingency (15%) | 4 |
| **Grand Total** | **30** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $99,428 |
| **USD** | $63,336 |

## 7. Assumptions
- PDF documentation provided; some reverse engineering may be required
- Complex production environment handled by Canva internal team
- Snowflake Cortex Code AI-assisted development is used
- Data volume manageable for rebuild from source approach
- SME availability at 4+ hours per week


## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Gathering | Discovery | 1.0 | 4% |
| Data Model Analysis | Analysis | 3.5 | 13% |
| DBT Model Analysis | Analysis | 2.7 | 10% |
| Star Schema Design | Design | 4.0 | 15% |
| Physical Layer Setup | Build | 0.5 | 2% |
| DBT Model Build | Build | 2.3 | 9% |
| Semantic Layer | Build | 3.7 | 14% |
| Orchestration Setup | Build | 2.5 | 10% |
| Testing | Testing | 5.0 | 19% |
| Documentation | Documentation | 2.0 | 8% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 1.0 | 4% |
| Analysis | 6.2 | 24% |
| Design | 4.0 | 15% |
| Build | 9.0 | 35% |
| Testing | 5.0 | 19% |
| Documentation | 2.0 | 8% |

**Key Insight:** Build (35%) is the largest component, followed by Analysis (24%) and Testing (19%). Design (15%) is significant as column classification requires human judgment to properly separate dimensional attributes from fact measures.

## 9. Recommendation
**✅ EXECUTE** - Well-scoped engagement with clear deliverables. Star schema redesign will significantly improve query performance and analytical flexibility.

---

# Domain 3: Product Experience - Macros Consolidation

## 1. Scope
- Design and build 5 parameterised DBT macros for standardised reporting (MAU, Retention, Funnel, Health/Engagement, Audience)
- Consolidate fragmented implementations across teams (GenAI, TE, DE)
- Create metrics layer dimensional models for macro outputs
- Build 5 semantic views for Snowflake Intelligence
- Configure Airflow orchestration for automated metric generation

## 2. Migration
- **Existing:** Multiple fragmented implementations across teams
  - MAU: 1-2 permutations
  - Retention: 1-2 permutations
  - Funnel: ~3 permutations (GenAI, TE, DE)
  - Health/Engagement: ~2 permutations
- **Migration Work:**
  - Discovery and consolidation of existing approaches into 5 standardised macros
  - Create metrics layer dimensional models
  - Create 5 semantic views for Snowflake Intelligence
  - Configure Airflow orchestration

## 3. New
- **Audience macro** - Dynamic criteria-based segmentation (greenfield, no prior art)

## 4. Outcomes
Canva will receive:
- ✅ 5 standardised, parameterised DBT macros (MAU, Retention, Funnel, Health/Engagement, Audience) usable across all teams
- ✅ Elimination of duplicate implementations with 5 semantic views enabling natural language metric queries
- ✅ Complete macro specifications, usage documentation, and consistent dimensional modelling

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 62 |
| Contingency (15%) | 9 |
| **Grand Total** | **71** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $262,313 |
| **USD** | $167,093 |

## 7. Assumptions
- Source data available in standardised input format
- Design approval obtained for each macro before build begins
- Existing permutation owners available for discovery sessions
- No historical backfill required (separate activity if needed)
- Unit test development explicitly out of scope

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Existing Implementation Discovery | Discovery | 12.4 | 20% |
| Macro Design | Design | 11.5 | 19% |
| Physical Layer Setup | Build | 0.5 | 1% |
| Macro Build | Build | 14.7 | 24% |
| Semantic Layer | Build | 6.5 | 10% |
| Orchestration Setup | Build | 2.6 | 4% |
| Testing | Testing | 9.5 | 15% |
| Documentation | Documentation | 4.0 | 6% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 12.4 | 20% |
| Analysis | 0.0 | 0% |
| Design | 11.5 | 19% |
| Build | 24.3 | 39% |
| Testing | 9.5 | 15% |
| Documentation | 4.0 | 6% |

**Key Insight:** Build (39%) is the largest component, followed by Discovery (20%) and Design (19%). Discovery is substantial due to the need to understand fragmented implementations across multiple teams. Design complexity requires stakeholder collaboration to consolidate requirements.

## 9. Recommendation
**✅ EXECUTE** - High strategic value. Standardised macros will eliminate duplication and ensure consistent metrics across all Product Experience teams.

---

# Domain 4: Marketing Domain

## 1. Scope
- Design and build new Marketplace Flow Pipeline for marketing analytics
- Create Metrics layer dimensional model for marketplace session tracking
- Develop ~8 DBT models consuming Discovery + Foundation domain data
- Build 3 semantic views (Marketplace Landing Page, Editor Outcomes, Attribution)
- Configure daily Airflow orchestration for automated refresh

## 2. Migration
- **Existing:** No existing DBT models
- **Migration Work:** None

## 3. New
- New Marketplace Flow Pipeline (greenfield development)
- ~8 new DBT models for transformation logic
- 3 semantic views (Marketplace Landing Page, Editor Outcomes, Attribution analytics)
- Daily Airflow orchestration

## 4. Outcomes
Canva will receive:
- ✅ Complete Marketplace Flow Pipeline with session-level funnel tracking (search → ingredient interaction → application)
- ✅ Attribution logic linking marketplace sessions to editor outcomes with 3 semantic views
- ✅ Daily refresh capability with complete solution design and data architecture documentation

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 32 |
| Contingency (15%) | 5 |
| **Grand Total** | **37** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $118,569 |
| **USD** | $75,528 |

## 7. Assumptions
- Upstream dependencies from Discovery and Foundation domains complete (ARR ticket raised)
- Initial business requirements documented and available
- No governance changes required (uses existing marketing RBAC roles)
- Attribution logic complexity aligns with initial assessment

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Discovery | Discovery | 5.6 | 18% |
| Data Model Design | Design | 6.5 | 20% |
| Physical Layer Setup | Build | 0.5 | 2% |
| DBT Model Build | Build | 3.4 | 11% |
| Semantic Layer | Build | 7.1 | 22% |
| Orchestration Setup | Build | 1.7 | 5% |
| Testing | Testing | 5.0 | 16% |
| Documentation | Documentation | 2.7 | 8% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 5.6 | 18% |
| Analysis | 0.0 | 0% |
| Design | 6.5 | 20% |
| Build | 12.7 | 40% |
| Testing | 5.0 | 16% |
| Documentation | 2.7 | 8% |

**Key Insight:** Build (40%) and Design (20%) are the largest components. No Analysis required as this is greenfield development with no existing code to analyse. Discovery (18%) focuses on understanding business requirements and upstream dependencies.

## 9. Recommendation
**✅ EXECUTE** - Greenfield development with clear upstream dependencies. Lower risk due to no migration complexity.

---

# Domain 5: Print Domain

## 1. Scope
- Analyse, redesign, and rebuild existing DBT project into three-layer architecture
- Restructure 2 monolithic fact tables into ~9 grain-appropriate models
- Migrate 7.5 billion rows of historical fact_print_funnel data
- Create 2 semantic views for Snowflake Intelligence
- Configure orchestration (2-hour near real-time + daily schedules)

## 2. Migration
- **Existing:** 2 monolithic tables (fact_print_funnel, fact_print_ordered), ~30 DBT models
- **Migration Work:**
  - Create 3 Snowflake databases (print_conformed, print_metrics, print_semantic)
  - Analyse and rebuild ~30 existing DBT models into ~9 grain-appropriate models
  - Create 2 semantic views for Snowflake Intelligence
  - Full historical migration for fact_print_funnel (7.5B rows, 2.5TB)
  - Configure Airflow orchestration (2-hour event-based + daily scheduled)

## 3. New
- None (all work relates to migrating/restructuring existing pipelines)

## 4. Outcomes
Canva will receive:
- ✅ Modernised three-layer architecture with phase-based analytical models (Cart, Proofing, Checkout, Fulfillment) and grain-appropriate fact tables
- ✅ 7.5B rows migrated with 2 semantic views enabling natural language queries via Snowflake Intelligence
- ✅ Near real-time (2-hour) refresh capability with complete documentation and migration guide

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 59 |
| Contingency (15%) | 9 |
| **Grand Total** | **68** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $221,558 |
| **USD** | $141,133 |

## 7. Assumptions
- HLDD and sample DBT models provided in Week 1-2
- Kevin to communicate with other domain owners about intermediary table usage
- Source data already available in Snowflake (no ingestion required)
- Revenue allocation rules will be defined during design phase
- Code sharing mechanism available during engagement

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Gathering | Discovery | 2.0 | 3% |
| Data Model Analysis | Analysis | 8.5 | 14% |
| DBT Model Analysis | Analysis | 6.0 | 10% |
| Target Model Design | Design | 7.0 | 12% |
| Physical Layer Setup | Build | 1.0 | 2% |
| DBT Model Build | Build | 14.4 | 24% |
| Semantic Layer | Build | 7.5 | 13% |
| Orchestration Setup | Build | 4.9 | 8% |
| Historical Data Migration | Build | 4.9 | 8% |
| Testing | Testing | 4.4 | 7% |
| Documentation | Documentation | 3.3 | 6% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 2.0 | 3% |
| Analysis | 14.5 | 25% |
| Design | 7.0 | 12% |
| Build | 32.7 | 55% |
| Testing | 4.4 | 7% |
| Documentation | 3.3 | 6% |

**Key Insight:** Build activities (55%) dominate due to DBT model reconstruction and historical data migration. Analysis (25%) is substantial due to reverse engineering required. Design (12%) reflects the complexity of decomposing monolithic tables into grain-appropriate models.

## 9. Recommendation
**✅ EXECUTE** - Critical domain with significant historical data. Modernisation will enable phase-based analytics and near real-time reporting.

---

# Domain 6: Monetisation Domain

## 1. Scope
- Analyse, redesign, and rebuild existing DBT project into three-layer architecture
- Build models for 4 reporting pipelines: Merchant Fee, Payout, Coupon & Offer, Refund & Dispute
- Migrate historical data with validation
- Implement data governance (classifications, masking, RAP, RBAC)
- Create 4 semantic views for Snowflake Intelligence natural language queries

## 2. Migration
- **Existing:** 14 tables across 4 reporting areas, 31 DBT models
- **Migration Work:**
  - Create 3 Snowflake databases (Conformed, Metrics, Semantic)
  - Analyse and rebuild 31 DBT models
  - Create 4 semantic views (Merchant Fee, Payout, Coupon & Offer, Refund & Dispute)
  - Full historical data migration with validation
  - Configure event-based and scheduled Airflow orchestration
  - Implement governance framework (masking policies, RAP, RBAC)

## 3. New
- None (all work relates to migrating/restructuring existing pipelines)

## 4. Outcomes
Canva will receive:
- ✅ Modernised three-layer architecture for all monetisation reporting (Gateway, Payout, Coupon, Refund/Dispute)
- ✅ 4 semantic views for natural language queries with full data governance implementation
- ✅ Historical data migrated and validated with complete migration guide for downstream consumers

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 88 |
| Contingency (15%) | 13 |
| **Grand Total** | **102** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $322,487 |
| **USD** | $205,424 |

## 7. Assumptions
- Subscription Data Transformation Pipeline requires separate workshop (out of scope)
- YAML documentation exists for DBT models (minimal reverse engineering)
- Metrics Alerts confirmation pending from Nicholas Prima
- Foundation domain tables consumed as-is

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Gathering | Discovery | 2.0 | 2% |
| Data Model Analysis | Analysis | 7.0 | 8% |
| DBT Model Analysis | Analysis | 9.5 | 11% |
| Target Model Design | Design | 9.8 | 11% |
| Physical Layer Setup | Build | 1.0 | 1% |
| DBT Model Build | Build | 18.1 | 21% |
| Semantic Layer | Build | 7.1 | 8% |
| Orchestration Setup | Build | 6.3 | 7% |
| Governance | Build | 8.0 | 9% |
| Historical Data Migration | Build | 8.9 | 10% |
| Testing | Testing | 4.2 | 5% |
| Documentation | Documentation | 9.0 | 10% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 2.0 | 2% |
| Analysis | 16.5 | 19% |
| Design | 9.8 | 11% |
| Build | 49.4 | 56% |
| Testing | 4.2 | 5% |
| Documentation | 9.0 | 10% |

**Key Insight:** Build (56%) dominates due to DBT model reconstruction, governance implementation, and historical data migration. Analysis (19%) benefits from existing YAML documentation. Documentation (10%) is higher due to downstream consumer migration guides.

## 9. Recommendation
**✅ EXECUTE** - Business-critical domain for financial reporting. Governance implementation essential for sensitive payment and payout data.

---

# Domain 7: Pilot (Feature Catalog)

## 1. Scope
- Add surrogate keys to 3 fact tables in existing conformed database
- Create 1 new dimension table for improved join performance
- Repoint 16 fact tables to new metrics database location via DBT modifications
- Configure event-triggered Airflow orchestration
- Deliver production deployment guide and architecture documentation

## 2. Migration
- **Existing:** Feature Catalog DBT project with three-layer architecture already in place
- **Migration Work:**
  - Create Feature Catalog Metrics database with appropriate schemas
  - DBT model modifications for surrogate key addition (3 tables)
  - Repointing 16 DBT models to new database location
  - Migrate orchestration from Kubernetes to Airflow

## 3. New
- 1 new dimension table

## 4. Outcomes
Canva will receive:
- ✅ Restructured Feature Catalog with metrics layer database and surrogate keys for improved join performance
- ✅ 16 fact tables properly organised in new metrics layer with event-triggered Airflow orchestration
- ✅ Production deployment guide with complete solution design and data architecture documentation

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 19 |
| Contingency (15%) | 3 |
| **Grand Total** | **22** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $71,673 |
| **USD** | $45,656 |

## 7. Assumptions
- Existing DBT project structure is well-documented and understood
- SME availability at 4+ hours per week for requirements clarification
- Airflow V2 supports event triggering (alternative approach adds 3-5 days if not available)
- Semantic views explicitly de-scoped per stakeholder confirmation
- Production deployment handled by Canva internal team
- Snowflake Cortex Code AI-assisted development is used


## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Requirements Gathering | Discovery | 0.5 | 2% |
| Surrogate Key Analysis | Analysis | 2.9 | 14% |
| Target State Design | Design | 1.0 | 5% |
| DBT Model Repointing | Build | 3.7 | 18% |
| Orchestration Setup | Build | 3.4 | 16% |
| Testing & Deployment | Testing | 4.5 | 21% |
| Documentation & Handover | Documentation | 3.4 | 17% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 0.5 | 2% |
| Analysis | 2.9 | 14% |
| Design | 1.0 | 5% |
| Build | 7.1 | 34% |
| Testing | 4.5 | 21% |
| Documentation | 3.4 | 17% |

**Key Insight:** Build activities (37%) represent the largest effort, followed by Testing (23%) and Documentation (17%) which now benefits from AI acceleration. Design effort is minimal (5%) due to well-defined existing architecture.

## 9. Recommendation
**✅ EXECUTE** - Low-risk, well-defined scope with existing infrastructure. Ideal pilot domain to establish patterns for larger migrations.

---

# Domain 8: IT Domain (JIRA Analytics)

## 1. Scope
- Discover and evaluate ingestion methodologies (Delta Share vs OpenFlow)
- Analyse and redesign 150 existing DBT models into four-layer architecture
- Build data models for 7 JIRA entities with target 50% model consolidation
- Create 7 semantic views for Snowflake Intelligence
- Implement data governance (classifications, masking, tagging)

## 2. Migration
- **Existing:** 150 DBT models with significant duplication
- **Migration Work:**
  - Create 4 Snowflake databases (Landing, Conformed, Metrics, Semantic)
  - Evaluate and productionize ingestion pipeline (Delta Share or OpenFlow)
  - DBT model consolidation (target 50% reduction to ~75 models)
  - Create 7 semantic views (one per JIRA entity)
  - Migrate orchestration from Snowflake Tasks to Airflow
  - Implement data governance framework (classifications, tagging, masking policies)

## 3. New
- None (all work relates to migrating/restructuring existing pipelines and ingestion)

## 4. Outcomes
Canva will receive:
- ✅ Production-ready ingestion pipeline with four-layer architecture and ~75 consolidated DBT models (50% reduction)
- ✅ Data models for 7 JIRA entities with 7 semantic views enabling natural language analytics
- ✅ Data governance framework with classifications and masking policies, complete documentation and runbooks

## 5. Effort
| Category | Days |
|----------|------|
| AI-Enhanced Base Effort | 113 |
| Contingency (15%) | 17 |
| **Grand Total** | **130** |

## 6. Investment
| Currency | Amount |
|----------|--------|
| **AUD** | $384,348 |
| **USD** | $244,830 |

## 7. Assumptions
- DEV environment only (production deployment out of scope)
- Delta Share POC exists (stored procedures + Python)
- No historical data migration required
- Legacy JIRA instance capacity dependent (adds 15-25 days if included)
- SME availability at 4+ hours per week

- Snowflake Cortex Code AI-assisted development is used

## 8. Effort Analysis
| Activity Category | Higher-Level Category | Effort (Days) | % |
|-------------------|----------------------|---------------|---|
| Ingestion Discovery | Discovery | 16.0 | 14% |
| DBT Model Analysis | Analysis | 20.7 | 18% |
| Target Model Design | Design | 11.3 | 10% |
| Physical Layer Setup | Build | 1.5 | 1% |
| Ingestion Build | Build | 9.0 | 8% |
| DBT Model Build | Build | 12.3 | 11% |
| Entity Data Modelling | Build | 12.3 | 11% |
| Semantic Layer | Build | 9.9 | 9% |
| Orchestration Setup | Build | 4.1 | 4% |
| Governance | Build | 4.0 | 4% |
| Testing | Testing | 4.0 | 4% |
| Documentation | Documentation | 7.5 | 7% |

| **Summary by Higher-Level Category** | **Days** | **%** |
|--------------------------------------|----------|-------|
| Discovery | 16.0 | 14% |
| Analysis | 20.7 | 18% |
| Design | 11.3 | 10% |
| Build | 53.1 | 47% |
| Testing | 4.0 | 4% |
| Documentation | 7.5 | 7% |

**Key Insight:** Build (47%) is the largest component due to ingestion pipeline, entity modelling, and governance implementation. Analysis (18%) reflects the 150 DBT model consolidation effort. Discovery (14%) is significant due to ingestion methodology evaluation.

## 9. Recommendation
**✅ EXECUTE** - Strategic domain enabling IT operational analytics. Ingestion discovery ensures optimal approach. Governance implementation establishes framework for other domains.

---

# Investment Summary

## Total Investment by Domain (AI-Enhanced)

| Domain | Days | AUD | USD |
|--------|------|-----|-----|
| Monetisation - Subscriptions | 189 | $613,534 | $390,821 |
| Product Experience - dim_editor_session | 30 | $99,428 | $63,336 |
| Product Experience - Macros | 71 | $262,313 | $167,093 |
| Marketing Domain | 37 | $118,569 | $75,528 |
| Print Domain | 68 | $221,558 | $141,133 |
| Monetisation Domain | 102 | $322,487 | $205,424 |
| Pilot (Feature Catalog) | 22 | $71,673 | $45,656 |
| IT Domain (JIRA Analytics) | 130 | $384,348 | $244,830 |
| **GRAND TOTAL** | **649** | **$2,093,910** | **$1,333,821** |

## Investment by Higher-Level Category

| Work Type | Total Days | % of Total |
|-----------|------------|------------|
| Discovery | ~45 | 7% |
| Analysis | ~120 | 18% |
| Design | ~75 | 12% |
| Build | ~290 | 45% |
| Testing | ~50 | 8% |
| Documentation | ~45 | 7% |
| Contingency | ~26 | 4% |

## AI Acceleration Value

This engagement leverages Cortex Code AI assistance to achieve **30% effort reduction** on scalable activities (analysis, DBT development, documentation generation):

| Metric | Value |
|--------|-------|
| Base Estimate (without AI) | 842 days |
| AI-Enhanced Estimate | 649 days |
| **Days Saved** | **193 days** |
| **Cost Savings (AUD)** | **$622,232** |
| **Cost Savings (USD)** | **$396,362** |

---

## Recommended Execution Order

1. **Monetisation - Subscriptions** - Highest priority, critical subscription analytics
2. **Product Experience - dim_editor_session** - Clear scope, star schema redesign
3. **Product Experience - Macros** - Consolidation initiative, standardised metrics
4. **Marketing Domain** - Greenfield, lower complexity
5. **Print Domain** - Critical domain with historical migration
6. **Monetisation Domain** - Financial reporting with governance
7. **Pilot Domain** - Establish patterns and processes
8. **IT Domain** - Ingestion discovery with governance framework

---

*Document generated: February 2026*  
*Prepared by: Snowflake Professional Services*  
*All estimates include AI-enhanced productivity through Cortex Code*
