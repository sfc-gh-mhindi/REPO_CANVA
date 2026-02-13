# Product Experience (Gen AI) Domain Data Migration - Scope of Work (INTERNAL)

**Client:** Canva  
**Domain:** Product Experience - Gen AI (Canva AI Preview & Ingredient Generation)  
**Prepared by:** Snowflake Professional Services  
**Date:** February 2026  
**Version:** 1.0 (DRAFT)  
**Document Status:** For Review

---

## Engagement Outcome

This outcome-based engagement will deliver the data model redesign and DBT migration for the Product Experience - Gen AI Domain as part of Canva's enterprise data migration initiative. Snowflake will decompose the existing monolithic fact table (fact_canva_ai_preview) into multiple smaller fact tables, integrate the ingredient generation service data source, migrate and refactor the associated DBT models from the monolithic transform project into the Product Experience domain's DBT project, and deliver complete documentation.

---

## Table of Contents

1. [In-Scope Pipelines](#1-in-scope-pipelines)
2. [Out of Scope](#2-out-of-scope)
3. [Effort Estimate](#3-effort-estimate)
   - 3.1 Assumptions Made on Estimate Calculation
   - 3.2 Effort Estimates - Detailed Breakdown
   - 3.3 Effort Summary
   - 3.4 Breakdown by Phase
   - 3.5 Phase-by-Phase Calculation
   - 3.6 Consolidated Effort Table
   - 3.7 Estimate Sensitivity
4. [High-Level Execution Plan](#4-high-level-execution-plan)
5. [Resourcing Needs](#5-resourcing-needs)
6. [Open Questions](#6-open-questions)
7. [Risks and Assumptions](#7-risks-and-assumptions)

---

## 1. In-Scope Pipelines

### 1.1 Architecture Overview

This engagement involves migration from the monolithic transform DBT project AND data model redesign to expand coverage. The current monolithic fact table will be decomposed into multiple fact tables to better represent the funnel structure and accommodate additional data sources.

| Layer | Current State | Future State |
|-------|---------------|--------------|
| **Source Data** | Monolithic DBT project (transform) | Product Experience domain DBT project |
| **Conformed Layer** | N/A | Create Product Experience conformed database |
| **Metrics Layer** | fact_canva_ai_preview (single monolithic table) | Multiple decomposed fact tables |
| **Semantic Layer** | N/A | Out of scope |

### 1.2 Data Pipelines

| Pipeline | Current State | Future State | Description |
|----------|---------------|--------------|-------------|
| **Canva AI Preview Journey** | Single monolithic fact table | Decomposed into ~4 fact tables | Track generation attempts, funnel movement, successful journeys, navigation |
| **Ingredient Generation** | Raw data available in Snowflake | Integrated into new model | 4TB source data (subset to be used - successful generations only) |

**Key Changes:**
- Decompose 1 monolithic fact table into ~4 smaller fact tables (customer has target state design)
- Integrate ingredient generation service data (already landed in Snowflake from DynamoDB)
- Migrate and refactor ~10 DBT models from monolithic transform project
- Expand DBT models to accommodate new entities and data sources
- Self-referencing parent-child relationships in ingredient data require special handling
- Two-level nested structure allows for efficient flattening in transformations

### 1.3 Current Data Volumes

| Data Source | Volume | Notes |
|-------------|--------|-------|
| **Ingredient Generation Data** | ~4 TB total | Only successful generations subset required |
| **Existing fact_canva_ai_preview** | TBD | To be decomposed |
| **Daily Row Volume** | TBD | Awaiting confirmation from Jeff |

**Note:** No data migration is required. Data can be rebuilt without historical migration per stakeholder confirmation.

### 1.4 Deliverables Summary

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Physical Layer Setup** | Create Product Experience conformed and metrics databases with appropriate schemas |
| 2 | **Data Model Design** | Design decomposed fact table structure (target state) |
| 3 | **DBT Model Migration** | Migrate ~10 DBT models from monolithic transform project |
| 4 | **DBT Model Refactoring** | Refactor DBT models to produce decomposed fact table structure |
| 5 | **New Data Source Integration** | Integrate ingredient generation service data into target model |
| 6 | **Orchestration Setup** | Configure orchestration in Airflow |
| 7 | **Testing** | Data quality tests, integration tests |
| 8 | **Documentation** | Solution design document, data architecture document |

---

## 2. Out of Scope

| Item | Rationale |
|------|-----------|
| **Data Ingestion** | Ingredient generation data already lands in Snowflake from DynamoDB |
| **Semantic Layer / Semantic Views** | De-scoped; customer assumes 1 semantic view could cover most business questions but requires further analysis |
| **Data Migration** | Data can be rebuilt; no historical migration required |
| **Governance Controls** | No governance policies or classifications required |
| **Productionization** | Handled by Canva internal team |
| **UAT/Production Deployment** | MH effort restricted to DEV environment only |
| **PII Handling in Dev** | Compliance team to address PII data visibility in dev environments separately |

---

## 3. Effort Estimate

### 3.1 Assumptions Made on Estimate Calculation

#### 3.1.1 DBT Model Complexity Distribution

| Complexity | Count | Description |
|------------|-------|-------------|
| **Current DBT models** | ~10 | Models currently generating the monolithic fact table |
| **Target fact tables** | ~4 | Decomposed fact tables in target state |
| **New integrated entities** | 1+ | Ingredient generation service integration |

*Note: Customer has target state design in mind; effort assumes design validation and implementation.*

#### 3.1.2 Effort per Activity Type

| Activity Type | Definition | Effort per Unit |
|---------------|------------|-----------------|
| **DBT Model Migration** | Moving model from monolith to domain project | 0.5 days per model |
| **DBT Model Refactoring** | Restructuring model for new target state | 1.0 days per model |
| **New Fact Table Creation** | Creating new decomposed fact table | 1.5 days per table |
| **Data Source Integration** | Integrating new data source into model | 2.0 days |

#### 3.1.3 Other Key Assumptions

| Assumption | Value | Impact |
|------------|-------|--------|
| Customer has target state design | Yes | Reduces design effort |
| Self-referencing structure | Two-level fixed depth | Allows efficient flattening |
| Ingredient data subset | Successful generations only | Reduces data volume |
| Data rebuild vs migration | Rebuild | No migration complexity |

| Factor | Estimate | Notes |
|--------|----------|-------|
| Source DBT models | ~10 | Currently generating monolithic table |
| Target fact tables | ~4 | Decomposed structure |
| Data volume (ingredients) | 4TB total, subset TBD | Only successful generations |
| Platform tooling | V2X | Standard domain tooling |
| Orchestration requirement | Airflow | Event-triggered patterns |
| Environment scope | DEV only | No production deployment effort |

---

### 3.2 Effort Estimates - Detailed Breakdown

#### 3.2.1 Physical Layer Setup

*Note: MH effort assumes DEV environment setup only.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Database creation | Create Product Experience conformed and metrics databases | 0.5 |
| Schema creation | Create schemas per database: source, internal, expose | 0.25 |
| Access configuration | Initial role grants and access setup | 0.25 |
| **Subtotal** | | **1.0** |

#### 3.2.2 Data Model Design & Analysis

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| Current state analysis | Review existing monolithic fact table and DBT models | 10 models x 0.25 days | 2.5 |
| Target state validation | Validate customer's target state design | | 1.0 |
| Ingredient data analysis | Analyse ingredient generation data structure and relationships | | 1.0 |
| **Subtotal** | | | **4.5** |

#### 3.2.3 DBT Model Migration

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| DBT project setup | Set up Product Experience domain DBT project structure | | 0.5 |
| Model migration | Migrate 10 DBT models from monolithic project | 10 models x 0.5 days | 5.0 |
| Configuration migration | Migrate YAML configs, tests, documentation | | 1.0 |
| **Subtotal** | | | **6.5** |

#### 3.2.4 DBT Model Refactoring

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| Refactoring design | Design refactored model structure for decomposition | | 1.0 |
| Model refactoring | Refactor DBT models for 4 target fact tables | 4 tables x 1.5 days | 6.0 |
| Parent-child handling | Implement self-referencing relationship handling | | 1.5 |
| **Subtotal** | | | **8.5** |

#### 3.2.5 New Data Source Integration

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Source mapping | Map ingredient generation data to target model | 1.0 |
| Integration development | Develop integration logic for ingredient data | 2.0 |
| Filtering logic | Implement successful generations filter | 0.5 |
| Testing integration | Validate integrated data | 1.0 |
| **Subtotal** | | **4.5** |

#### 3.2.6 Orchestration Setup

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Orchestration design | Design Airflow DAG structure | 0.5 |
| Airflow DAG development | Develop orchestration DAGs | 1.5 |
| Testing & validation | End-to-end orchestration testing | 1.0 |
| **Subtotal** | | **3.0** |

#### 3.2.7 Testing

*Note: Deployment to UAT and production environments is not included in MH effort scope.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Integration testing | End-to-end pipeline validation | 2.0 |
| Data quality testing | Accuracy, completeness, consistency | 2.0 |
| Regression testing | Validate decomposed output matches original logic | 1.5 |
| **Subtotal** | | **5.5** |

#### 3.2.8 Documentation

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Solution design document | Architecture and design documentation | 2.0 |
| Data architecture document | Data model specifications (decomposed structure) | 1.5 |
| Knowledge transfer | 1 session x 1 hour | 0.25 |
| **Subtotal** | | **3.75** |

#### 3.2.9 Deployment

*Note: MH effort is restricted to DEV environment only.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Development environment deployment | Initial deployment and validation | 1.0 |
| **Subtotal** | | **1.0** |

---

### 3.3 Effort Summary

| Category | Effort (Days) |
|----------|---------------|
| Physical Layer Setup | 1.0 |
| Data Model Design & Analysis | 4.5 |
| DBT Model Migration | 6.5 |
| DBT Model Refactoring | 8.5 |
| New Data Source Integration | 4.5 |
| Orchestration Setup | 3.0 |
| Testing | 5.5 |
| Documentation | 3.75 |
| Deployment | 1.0 |
| **Total Base Effort** | **38.25 days** |
| **Contingency (15%)** | **5.74 days** |
| **Grand Total** | **43.99 days** |

---

### 3.4 Breakdown by Phase

| Phase | Activities Included | Effort (Days) |
|-------|---------------------|---------------|
| **Phase 1: Discovery & Design** | Physical layer setup, data model design & analysis | 5.5 |
| **Phase 2: Migration** | DBT model migration | 6.5 |
| **Phase 3: Build** | DBT model refactoring, new data source integration, orchestration | 16.0 |
| **Phase 4: Testing & Deployment** | Testing, deployment | 6.5 |
| **Phase 5: Documentation & Handover** | Documentation, knowledge transfer | 3.75 |
| **Subtotal** | | **38.25** |
| **Contingency (15%)** | | **5.74** |
| **Grand Total** | | **43.99** |

---

### 3.5 Phase-by-Phase Calculation

#### Phase 1: Discovery & Design (5.5 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Physical layer setup | 1.0 | Databases + schemas + access |
| Current state analysis | 2.5 | 10 models x 0.25 days |
| Target state validation | 1.0 | Validate customer design |
| Ingredient data analysis | 1.0 | Data structure review |
| **Subtotal** | **5.5** | |

#### Phase 2: Migration (6.5 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| DBT project setup | 0.5 | Domain project structure |
| Model migration | 5.0 | 10 models x 0.5 days |
| Configuration migration | 1.0 | YAML configs, tests, docs |
| **Subtotal** | **6.5** | |

#### Phase 3: Build (16.0 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Refactoring design | 1.0 | Model structure design |
| Model refactoring | 6.0 | 4 tables x 1.5 days |
| Parent-child handling | 1.5 | Self-referencing relationships |
| Source mapping | 1.0 | Ingredient data mapping |
| Integration development | 2.0 | Integration logic |
| Filtering logic | 0.5 | Successful generations filter |
| Testing integration | 1.0 | Validate integrated data |
| Orchestration design | 0.5 | Airflow DAG structure |
| Airflow DAG development | 1.5 | Orchestration DAGs |
| Orchestration testing | 1.0 | End-to-end validation |
| **Subtotal** | **16.0** | |

#### Phase 4: Testing & Deployment (6.5 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Integration testing | 2.0 | End-to-end validation |
| Data quality testing | 2.0 | Accuracy, completeness |
| Regression testing | 1.5 | Compare with original |
| Dev environment deployment | 1.0 | Initial deployment |
| **Subtotal** | **6.5** | |

#### Phase 5: Documentation & Handover (3.75 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Solution design document | 2.0 | Architecture documentation |
| Data architecture document | 1.5 | Data model specs |
| Knowledge transfer | 0.25 | 1 session x 1 hour |
| **Subtotal** | **3.75** | |

---

### 3.6 Consolidated Effort Table

| Category | Phase | Activity | Effort (Days) | Calculation |
|----------|-------|----------|---------------|-------------|
| **Physical Layer Setup** | 1 | Database creation | 0.5 | 2 databases |
| | 1 | Schema creation | 0.25 | Schemas per database |
| | 1 | Access configuration | 0.25 | Initial role grants |
| | | **Subtotal** | **1.0** | |
| **Data Model Design & Analysis** | 1 | Current state analysis | 2.5 | 10 models |
| | 1 | Target state validation | 1.0 | Customer design |
| | 1 | Ingredient data analysis | 1.0 | Data structure |
| | | **Subtotal** | **4.5** | |
| **DBT Model Migration** | 2 | DBT project setup | 0.5 | Project structure |
| | 2 | Model migration | 5.0 | 10 models x 0.5 days |
| | 2 | Configuration migration | 1.0 | YAML configs |
| | | **Subtotal** | **6.5** | |
| **DBT Model Refactoring** | 3 | Refactoring design | 1.0 | Model structure |
| | 3 | Model refactoring | 6.0 | 4 tables x 1.5 days |
| | 3 | Parent-child handling | 1.5 | Self-referencing |
| | | **Subtotal** | **8.5** | |
| **New Data Source Integration** | 3 | Source mapping | 1.0 | Ingredient mapping |
| | 3 | Integration development | 2.0 | Integration logic |
| | 3 | Filtering logic | 0.5 | Successful generations |
| | 3 | Testing integration | 1.0 | Validate data |
| | | **Subtotal** | **4.5** | |
| **Orchestration Setup** | 3 | Orchestration design | 0.5 | DAG structure |
| | 3 | Airflow DAG development | 1.5 | DAG development |
| | 3 | Testing & validation | 1.0 | End-to-end testing |
| | | **Subtotal** | **3.0** | |
| **Testing** | 4 | Integration testing | 2.0 | End-to-end validation |
| | 4 | Data quality testing | 2.0 | Accuracy, completeness |
| | 4 | Regression testing | 1.5 | Compare with original |
| | | **Subtotal** | **5.5** | |
| **Deployment** | 4 | Dev environment deployment | 1.0 | Initial deployment |
| | | **Subtotal** | **1.0** | |
| **Documentation** | 5 | Solution design document | 2.0 | Architecture documentation |
| | 5 | Data architecture document | 1.5 | Data model specs |
| | 5 | Knowledge transfer | 0.25 | 1 session x 1 hour |
| | | **Subtotal** | **3.75** | |
| | | | | |
| **PHASE TOTALS** | | | | |
| | **Phase 1** | Discovery & Design | **5.5** | |
| | **Phase 2** | Migration | **6.5** | |
| | **Phase 3** | Build | **16.0** | |
| | **Phase 4** | Testing & Deployment | **6.5** | |
| | **Phase 5** | Documentation & Handover | **3.75** | |
| | | | | |
| | | **Total Base Effort** | **38.25** | |
| | | **Contingency (15%)** | **5.74** | |
| | | **Grand Total** | **43.99** | |

---

### 3.7 Estimate Sensitivity

| If This Changes... | Impact on Estimate |
|--------------------|--------------------|
| More than 10 source DBT models | +0.5 days per additional model (migration) |
| More than 4 target fact tables | +1.5 days per additional table (refactoring) |
| Target state design requires significant changes | +3-5 days (design iteration) |
| Ingredient data subset larger than expected | +2-3 days (additional filtering/processing) |
| Self-referencing depth > 2 levels | +3-5 days (complex handling) |
| Additional data source integration required | +3-5 days per source |
| SME availability drops to 2 hrs/week | +3-5 days (waiting time) |
| Production deployment included in scope | +5-8 days |
| Semantic views added to scope | +5-8 days |
| Data migration required instead of rebuild | +5-10 days |

---

## 4. High-Level Execution Plan

### Phase 1: Discovery & Design (Weeks 1-2)

**Objectives:** Set up infrastructure, analyse current state, validate target design

| Week | Activities |
|------|------------|
| 1 | Physical layer setup, current state analysis begins |
| 2 | Complete analysis, target state validation, ingredient data analysis |

**Key Milestones:**
- Product Experience databases created
- Current fact table and DBT models fully understood
- Target state design validated with customer
- Ingredient data structure documented

### Phase 2: Migration (Weeks 3-4)

**Objectives:** Migrate DBT models from monolithic project to domain project

| Week | Activities |
|------|------------|
| 3 | DBT project setup, begin model migration |
| 4 | Complete model migration, configuration migration |

**Key Milestones:**
- Product Experience DBT project established
- All 10 DBT models migrated
- Configurations and tests migrated

### Phase 3: Build (Weeks 5-7)

**Objectives:** Refactor DBT models, integrate new data source, set up orchestration

| Week | Activities |
|------|------------|
| 5 | Refactoring design, begin model refactoring |
| 6 | Complete refactoring, begin data source integration |
| 7 | Complete integration, orchestration setup |

**Key Milestones:**
- Decomposed fact tables created
- Ingredient generation data integrated
- Airflow orchestration operational

### Phase 4: Testing & Deployment (Weeks 8-9)

**Objectives:** Test thoroughly, deploy to DEV environment

| Week | Activities |
|------|------------|
| 8 | Integration testing, data quality testing |
| 9 | Regression testing, DEV deployment |

**Key Milestones:**
- All tests passing
- DEV deployment complete
- Output validated against original logic

### Phase 5: Documentation & Handover (Week 10)

**Objectives:** Document solution, transfer knowledge

| Week | Activities |
|------|------------|
| 10 | Documentation completion, knowledge transfer |

**Key Milestones:**
- Documentation delivered
- Knowledge transfer complete

### Timeline Summary

```
===============================================================================
                PRODUCT EXPERIENCE (GEN AI) - PROJECT TIMELINE (10 WEEKS)
===============================================================================

WEEK     1    2    3    4    5    6    7    8    9    10
         |    |    |    |    |    |    |    |    |    |
---------+----+----+----+----+----+----+----+----+----+

PHASE 1: DISCOVERY & DESIGN (5.5 days)
         =========
         Week 1-2

PHASE 2: MIGRATION (6.5 days)
                   =========
                   Week 3-4

PHASE 3: BUILD (16.0 days)
                        ===============
                        Week 5-7

PHASE 4: TESTING & DEPLOYMENT (6.5 days)
                                    =========
                                    Week 8-9

PHASE 5: DOCUMENTATION & HANDOVER (3.75 days)
                                             ====
                                             Week 10

===============================================================================
                              KEY MILESTONES
===============================================================================

  Wk 2  - Target state design validated
  Wk 4  - DBT models migrated
  Wk 6  - Fact table decomposition complete
  Wk 7  - Ingredient data integrated, orchestration operational
  Wk 9  - Testing complete, DEV deployed
  Wk 10 - Documentation delivered

===============================================================================
```

**Total Duration:** ~10 weeks

---

## 5. Resourcing Needs

### 5.1 Snowflake Professional Services Team

| Role | FTE | Duration | Responsibilities | Required Skills & Expertise |
|------|-----|----------|------------------|----------------------------|
| **Lead Solution Architect** | 1.0 | Full engagement (10 weeks) | Solution architecture, DBT migration, model refactoring, technical leadership, documentation | DBT Core, Snowflake, Data modeling, SQL, Airflow, Solution design |

### 5.2 Canva Team Requirements

| Role | Availability | Responsibilities |
|------|--------------|------------------|
| **Domain SME (Jeff)** | 4-6 hrs/week | Business context, requirements clarification, target state design review |
| **Platform Team** | Ad-hoc | Airflow support, environment access |
| **DBT Admin** | Ad-hoc | DBT project repository access, deployment support |

### 5.3 Resource Calendar

| Week | MH | Canva SME (Jeff) | Platform Team |
|------|-----|------------------|---------------|
| 1-2 | Full time | High (6 hrs/wk) | Ad-hoc |
| 3-4 | Full time | Medium (4 hrs/wk) | Ad-hoc |
| 5-7 | Full time | Medium (4 hrs/wk) | Ad-hoc |
| 8-9 | Full time | Low (2 hrs/wk) | Ad-hoc |
| 10 | Full time | Low (2 hrs/wk) | Ad-hoc |

---

## 6. Open Questions

| # | Question | Owner | Due Date | Impact if Unresolved |
|---|----------|-------|----------|---------------------|
| 1 | What is the anticipated percentage of successful generations in the ingredient generation data? | Jeff | TBD | Affects data volume and transformation requirements |
| 2 | What is the daily row volume for ingredient generation data? | Jeff | TBD | Affects performance design |
| 3 | Exact number of target fact tables in decomposed structure? | Jeff | TBD | Affects refactoring effort |
| 4 | What semantic views are anticipated (publish rate, conversion funnel, brand kit usage, etc.)? | Jeff | TBD | Future scope planning |
| 5 | DEV environment PR-based setup - any compliance concerns for PII visibility? | Compliance Team | TBD | May affect development approach |

---

## 7. Risks and Assumptions

### 7.1 Assumptions

| # | Assumption | Impact if Invalid |
|---|------------|-------------------|
| A1 | Customer has target state design for decomposed fact tables | Additional design effort required if not |
| A2 | Ingredient generation data already available in Snowflake (landed from DynamoDB) | Ingestion effort required if not |
| A3 | Self-referencing structure is fixed at two levels | Additional complexity if deeper nesting |
| A4 | Only successful generations subset required from 4TB ingredient data | Higher processing effort if more data needed |
| A5 | Data can be rebuilt; no historical migration required | Migration effort required if rebuild not acceptable |
| A6 | DEV environment available and accessible | Timeline delays if environment not ready |
| A7 | ~10 DBT models currently generate the monolithic fact table | Effort adjustment if count differs significantly |
| A8 | V2X platform tooling available for Product Experience domain | Alternative approach if tooling differs |
| A9 | Airflow available for orchestration | Alternative orchestration approach required if not |
| A10 | Cortex Code can be connected to target Snowflake environment | Development tooling |

### 7.2 Risks

| # | Risk | Probability | Impact | Mitigation |
|---|------|-------------|--------|------------|
| R1 | **Requirement document not yet available** - scoping based on meeting notes only | High | Medium | Validate assumptions when official requirements received; include contingency |
| R2 | Ingredient data subset size unknown - could be larger than expected | Medium | Medium | Early data profiling; adjust filtering strategy |
| R3 | Target state design may require iteration after validation | Medium | Medium | Include design review cycles; contingency covers iterations |
| R4 | Self-referencing relationships more complex than two levels | Low | High | Early data analysis; re-estimate if deeper nesting discovered |
| R5 | SME availability constrained during build phase | Medium | Medium | Front-load discovery sessions; document decisions |
| R6 | DEV environment PII compliance issues | Low | Medium | Work with compliance team early; anonymisation approach if needed |
| R7 | Project ranking/prioritisation may defer start date | Medium | Low | Coordinate with Helen and Adrian on timing |

### 7.3 Dependencies

| # | Dependency | Owner | Required By |
|---|------------|-------|-------------|
| D1 | Official requirement document | Jeff/Product Team | Phase 1 start |
| D2 | Target state design confirmation | Jeff | Phase 1 completion |
| D3 | DEV environment access | Platform Team | Phase 1 start |
| D4 | DBT project repository access | DBT Admin | Phase 2 start |
| D5 | Ingredient generation data access | Data Team | Phase 3 start |
| D6 | Airflow configuration access | Platform Team | Phase 3 |
| D7 | Project prioritisation decision | Helen/Adrian | Engagement start |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | February 2026 | MH | Initial draft based on meeting notes |

---

*This document is for Snowflake Professional Services internal use. Subject to revision pending official requirement document.*
