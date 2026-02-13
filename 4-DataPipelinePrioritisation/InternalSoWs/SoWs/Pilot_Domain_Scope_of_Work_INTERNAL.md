# Pilot Domain Data Migration - Scope of Work (INTERNAL)

**Client:** Canva  
**Domain:** Pilot (Feature Catalog & Experiment Analysis)  
**Prepared by:** Snowflake Professional Services  
**Date:** February 2026  
**Version:** 1.0 (DRAFT)  
**Document Status:** For Review

---

## Engagement Outcome

This outcome-based engagement will deliver the architectural restructuring and DBT model modifications for the Pilot Domain (Feature Catalog) as part of Canva's enterprise data migration initiative. Snowflake will create the Feature Catalog Metrics database, add surrogate keys to 3 fact tables in the existing conformed database, modify the corresponding DBT models, repoint 16 fact tables to the new metrics database location, configure event-triggered orchestration through Airflow, and deliver complete documentation including a production deployment guide.

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

The Pilot Domain already has an existing DBT project (Feature Catalog) with a three-layer architecture in place. The scope involves restructuring and enhancing this existing setup rather than migrating from a monolithic DBT project.

| Layer | Current State | Future State |
|-------|---------------|--------------|
| **Conformed Layer** | feature_catalog database (schemas: model, expose, source) | Repurpose existing feature_catalog database as conformed layer |
| **Metrics Layer** | Does not exist as separate database | Create new feature_catalog_metrics database |
| **Semantic Layer** | N/A | Out of scope |

### 1.2 Data Pipelines

| Pipeline | Current Tables | Changes Required | Description |
|----------|----------------|------------------|-------------|
| **Surrogate Key Addition** | 3 fact tables in conformed database | Add surrogate keys to 3 fact tables; create 1 new dimension table | Adding surrogate IDs to existing dimensions and exposing foreign keys |
| **Metrics Layer Migration** | 16 fact tables | Repoint DBT models to new database location | Move 16 fact tables from current database to new feature_catalog_metrics database |

**Key Changes:**
- 3 fact tables require surrogate key additions (remain in conformed database)
- 16 fact tables to be moved to new metrics database (DBT model repointing only)
- 1 new dimension table to be created
- DBT model to table relationship is one-to-one

### 1.3 Current Data Volumes

| Table Category | Count | Migration Required |
|----------------|-------|-------------------|
| **Fact tables requiring surrogate keys** | 3 | No - modifications only |
| **Fact tables to be moved to metrics** | 16 | No - DBT repointing only |
| **New dimension table** | 1 | N/A - new creation |

**Note:** No data migration is required. All changes are DBT model modifications and database restructuring.

### 1.4 Deliverables Summary

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Physical Layer Setup** | Create Feature Catalog Metrics database with appropriate schemas |
| 2 | **Surrogate Key Implementation** | Add surrogate keys to 3 fact tables in conformed database |
| 3 | **DBT Model Modifications** | Modify DBT models for surrogate key addition (3 tables) |
| 4 | **DBT Model Repointing** | Repoint 16 DBT models to new metrics database location |
| 5 | **New Dimension Table** | Create 1 new dimension table with corresponding DBT model |
| 6 | **Orchestration Setup** | Configure event-triggered Airflow orchestration based on foundation layer jobs |
| 7 | **Testing** | Data quality tests, unit tests, integration tests |
| 8 | **Documentation** | Solution design document, data architecture document |
| 9 | **Production Deployment Guide** | Document/guide for domain team to move from DEV to production |

---

## 2. Out of Scope

| Item | Rationale |
|------|-----------|
| **DBT Project Migration** | Domain already has own DBT project (Feature Catalog) - not migrating from monolithic |
| **Conformed Database Creation** | Existing feature_catalog database will be repurposed as conformed layer |
| **Semantic Layer / Semantic Views** | Explicitly de-scoped per stakeholder confirmation |
| **Data Migration** | No data movement required - DBT repointing and modifications only |
| **Governance Controls** | No governance policies or classifications required |
| **Productionization** | Handled by Canva internal team; production guide provided |
| **UAT/Production Deployment** | MH effort restricted to DEV environment only |
| **Data Model Redesign** | Existing data models remain unchanged; only surrogate keys added |
| **Downstream Consumer Re-pointing** | Migration guide provided, but actual re-pointing is consumer responsibility |

---

## 3. Effort Estimate

### 3.1 Assumptions Made on Estimate Calculation

#### 3.1.1 DBT Model Complexity Distribution

| Complexity | Percentage | Count | Description |
|------------|------------|-------|-------------|
| **Complex** | 10% | ~2 | Models requiring surrogate key changes (no changes needed to complex models) |
| **Medium** | 90% | ~17 | Models requiring repointing and modifications |

*Note: Per stakeholder confirmation, 10% complex models do not require changes; 90% medium models include those that need modifications. All changes are treated as medium complexity.*

#### 3.1.2 Effort per Model by Complexity

| Activity Type | Definition | Effort per Model |
|---------------|------------|------------------|
| **Surrogate Key Addition** | Adding surrogate IDs to existing fact tables | 0.5 days |
| **DBT Model Repointing** | Changing database/schema references | 0.25 days |
| **New Table Creation** | Creating new dimension table with DBT model | 1.0 days |

#### 3.1.3 Other Key Assumptions

| Assumption | Value | Impact |
|------------|-------|--------|
| DBT model to table relationship | One-to-one | Simplifies effort estimation |
| Existing DBT project | Feature Catalog (own project) | No monolith migration needed |
| Platform tooling | V2 (not V2X like other domains) | May impact orchestration approach |
| Orchestration requirement | Event-triggered from foundation layer | Airflow integration required |
| Environment scope | DEV only | No production deployment effort |

---

### 3.2 Effort Estimates - Detailed Breakdown

#### 3.2.1 Physical Layer Setup

*Note: MH effort assumes DEV environment setup only.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Database creation | Create feature_catalog_metrics database | 0.25 |
| Schema creation | Create schemas per database: source, internal, expose | 0.25 |
| Access configuration | Initial role grants and access setup | 0.25 |
| **Subtotal** | | **0.75** |

#### 3.2.2 Current State Analysis

*Note: Minimal analysis required as domain already has established DBT project and data models.*

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| DBT project review | Review existing Feature Catalog DBT project structure | | 0.5 |
| Table analysis | Analyse 3 fact tables for surrogate key addition | 3 tables x 0.25 days | 0.75 |
| **Subtotal** | | | **1.25** |

#### 3.2.3 Surrogate Key Implementation

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| Surrogate key design | Design surrogate key approach for 3 fact tables | | 0.5 |
| DBT model modifications | Modify 3 DBT models to add surrogate keys | 3 models x 0.5 days | 1.5 |
| New dimension table | Create 1 new dimension table with DBT model | 1 table x 1.0 days | 1.0 |
| Testing surrogate keys | Validate surrogate key implementation | | 0.5 |
| **Subtotal** | | | **3.5** |

#### 3.2.4 DBT Model Repointing

| Activity | Description | Calculation | Effort (Days) |
|----------|-------------|-------------|---------------|
| Repointing design | Design database reference changes | | 0.5 |
| DBT model modifications | Repoint 16 DBT models to new metrics database | 16 models x 0.25 days | 4.0 |
| Configuration updates | Update YAML configs for new database references | | 0.5 |
| **Subtotal** | | | **5.0** |

#### 3.2.5 Orchestration Setup

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Orchestration design | Design event-triggered patterns from foundation layer | 1.0 |
| Airflow DAG development | Migrate from Kubernetes cron jobs to Airflow | 2.0 |
| Testing & validation | End-to-end orchestration testing | 1.0 |
| **Subtotal** | | **4.0** |

#### 3.2.6 Testing

*Note: Deployment to UAT and production environments is not included in MH effort scope.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Integration testing | End-to-end pipeline validation | 2.0 |
| Data quality testing | Accuracy, completeness, consistency | 1.5 |
| **Subtotal** | | **3.5** |

#### 3.2.7 Documentation

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Solution design document | Architecture and design documentation | 2.0 |
| Data architecture document | Data model specifications | 1.0 |
| Production deployment guide | Guide for domain team to promote to production | 1.5 |
| Knowledge transfer | 1 session x 1 hour | 0.25 |
| **Subtotal** | | **4.75** |

#### 3.2.8 Deployment

*Note: MH effort is restricted to DEV environment only.*

| Activity | Description | Effort (Days) |
|----------|-------------|---------------|
| Development environment deployment | Initial deployment and validation | 1.0 |
| **Subtotal** | | **1.0** |

---

### 3.3 Effort Summary

| Category | Effort (Days) |
|----------|---------------|
| Physical Layer Setup | 0.75 |
| Current State Analysis | 1.25 |
| Surrogate Key Implementation | 3.5 |
| DBT Model Repointing | 5.0 |
| Orchestration Setup | 4.0 |
| Testing | 3.5 |
| Documentation | 4.75 |
| Deployment | 1.0 |
| **Total Base Effort** | **23.75 days** |
| **Contingency (15%)** | **3.56 days** |
| **Grand Total** | **27.31 days** |

---

### 3.4 Breakdown by Phase

| Phase | Activities Included | Effort (Days) |
|-------|---------------------|---------------|
| **Phase 1: Discovery & Design** | Physical layer setup, current state analysis | 2.0 |
| **Phase 2: Build** | Surrogate key implementation, DBT model repointing, orchestration | 12.5 |
| **Phase 3: Testing & Deployment** | Testing, deployment | 4.5 |
| **Phase 4: Documentation & Handover** | Documentation, knowledge transfer | 4.75 |
| **Subtotal** | | **23.75** |
| **Contingency (15%)** | | **3.56** |
| **Grand Total** | | **27.31** |

---

### 3.5 Phase-by-Phase Calculation

#### Phase 1: Discovery & Design (2.0 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Physical layer setup | 0.75 | 1 DB + schemas + access |
| DBT project review | 0.5 | Review existing project |
| Table analysis | 0.75 | 3 tables x 0.25 days |
| **Subtotal** | **2.0** | |

#### Phase 2: Build (12.5 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Surrogate key design | 0.5 | Design approach |
| DBT model modifications (surrogate keys) | 1.5 | 3 models x 0.5 days |
| New dimension table | 1.0 | 1 table x 1.0 days |
| Testing surrogate keys | 0.5 | Validation |
| Repointing design | 0.5 | Database reference changes |
| DBT model repointing | 4.0 | 16 models x 0.25 days |
| Configuration updates | 0.5 | YAML configs |
| Orchestration design | 1.0 | Event-triggered patterns |
| Airflow DAG development | 2.0 | Kubernetes to Airflow migration |
| Orchestration testing | 1.0 | End-to-end validation |
| **Subtotal** | **12.5** | |

#### Phase 3: Testing & Deployment (4.5 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Integration testing | 2.0 | End-to-end validation |
| Data quality testing | 1.5 | Accuracy, completeness |
| Dev environment deployment | 1.0 | Initial deployment |
| **Subtotal** | **4.5** | |

#### Phase 4: Documentation & Handover (4.75 days)

| Activity | Days | Calculation |
|----------|------|-------------|
| Solution design document | 2.0 | Architecture documentation |
| Data architecture document | 1.0 | Data model specs |
| Production deployment guide | 1.5 | Go-to-production guide |
| Knowledge transfer | 0.25 | 1 session x 1 hour |
| **Subtotal** | **4.75** | |

---

### 3.6 Consolidated Effort Table

| Category | Phase | Activity | Effort (Days) | AI Scalable | Effort with AI | Calculation |
|----------|-------|----------|---------------|-------------|----------------|-------------|
| **Physical Layer Setup** | 1 | Database creation | 0.25 | Yes | 0.175 | 1 database |
| | 1 | Schema creation | 0.25 | Yes | 0.175 | Schemas per database |
| | 1 | Access configuration | 0.25 | No | 0.25 | Initial role grants |
| | | **Subtotal** | **0.75** | | **0.6** | |
| **Current State Analysis** | 1 | DBT project review | 0.5 | Yes | 0.35 | Existing project |
| | 1 | Table analysis | 0.75 | Yes | 0.525 | 3 tables |
| | | **Subtotal** | **1.25** | | **0.875** | |
| **Surrogate Key Implementation** | 2 | Surrogate key design | 0.5 | Yes | 0.35 | Design approach |
| | 2 | DBT model modifications | 1.5 | Yes | 1.05 | 3 models x 0.5 days |
| | 2 | New dimension table | 1.0 | No | 1.0 | 1 table |
| | 2 | Testing surrogate keys | 0.5 | No | 0.5 | Validation |
| | | **Subtotal** | **3.5** | | **2.9** | |
| **DBT Model Repointing** | 2 | Repointing design | 0.5 | No | 0.5 | Database references |
| | 2 | DBT model modifications | 4.0 | Yes | 2.8 | 16 models x 0.25 days |
| | 2 | Configuration updates | 0.5 | Yes | 0.35 | YAML configs |
| | | **Subtotal** | **5.0** | | **3.65** | |
| **Orchestration Setup** | 2 | Orchestration design | 1.0 | No | 1.0 | Event-triggered patterns |
| | 2 | Airflow DAG development | 2.0 | Yes | 1.4 | Kubernetes to Airflow |
| | 2 | Testing & validation | 1.0 | No | 1.0 | End-to-end testing |
| | | **Subtotal** | **4.0** | | **3.4** | |
| **Testing** | 3 | Integration testing | 2.0 | No | 2.0 | End-to-end validation |
| | 3 | Data quality testing | 1.5 | No | 1.5 | Accuracy, completeness |
| | | **Subtotal** | **3.5** | | **3.5** | |
| **Deployment** | 3 | Dev environment deployment | 1.0 | No | 1.0 | Initial deployment |
| | | **Subtotal** | **1.0** | | **1.0** | |
| **Documentation** | 4 | Solution design document | 2.0 | No | 2.0 | Architecture documentation |
| | 4 | Data architecture document | 1.0 | No | 1.0 | Data model specs |
| | 4 | Production deployment guide | 1.5 | No | 1.5 | Go-to-production guide |
| | 4 | Knowledge transfer | 0.25 | No | 0.25 | 1 session x 1 hour |
| | | **Subtotal** | **4.75** | | **4.75** | |
| | | | | | | |
| **PHASE TOTALS** | | | | | | |
| | **Phase 1** | Discovery & Design | **2.0** | | **1.475** | |
| | **Phase 2** | Build | **12.5** | | **9.95** | |
| | **Phase 3** | Testing & Deployment | **4.5** | | **4.5** | |
| | **Phase 4** | Documentation & Handover | **4.75** | | **4.75** | |
| | | | | | | |
| | | **Total Base Effort** | **23.75** | | **20.675** | |
| | | **Contingency (15%)** | **3.56** | | **3.10** | |
| | | **Grand Total** | **27.31** | | **23.78** | |

---

### 3.7 Estimate Sensitivity

| If This Changes... | Impact on Estimate |
|--------------------|--------------------|
| Additional tables require surrogate keys beyond 3 | +0.5-1.0 days per table |
| More complex surrogate key logic required | +2-3 days |
| Additional DBT models beyond 16 require repointing | +0.25 days per model |
| Airflow event triggering not available in V2 | +3-5 days (alternative approach) |
| SME availability drops to 2 hrs/week | +3-5 days (waiting time) |
| Additional dimension tables required | +1.0 days per table |
| Production deployment included in scope | +5-8 days |
| Semantic views added to scope | +5-8 days |

---

## 4. High-Level Execution Plan

### Phase 1: Discovery & Design (Week 1)

**Objectives:** Review existing DBT project, design target state modifications

| Week | Activities |
|------|------------|
| 1 | Physical layer setup, DBT project review, table analysis for surrogate keys, design sign-off |

**Key Milestones:**
- Feature Catalog Metrics database created
- Target state design documented and approved
- Surrogate key approach defined

### Phase 2: Build (Weeks 2-4)

**Objectives:** Implement surrogate keys, repoint DBT models, configure orchestration

| Week | Activities |
|------|------------|
| 2 | Surrogate key implementation for 3 fact tables, new dimension table creation |
| 3 | DBT model repointing for 16 tables to metrics database |
| 4 | Airflow orchestration setup |

**Key Milestones:**
- Surrogate keys implemented
- All DBT models repointed
- Event-triggered orchestration operational

### Phase 3: Testing & Deployment (Weeks 5-6)

**Objectives:** Test thoroughly, deploy to DEV environment

| Week | Activities |
|------|------------|
| 5 | Integration testing |
| 6 | Data quality testing, DEV deployment |

**Key Milestones:**
- All tests passing
- DEV deployment complete

### Phase 4: Documentation & Handover (Week 7)

**Objectives:** Document solution, transfer knowledge, provide production guide

| Week | Activities |
|------|------------|
| 7 | Documentation completion, production deployment guide, knowledge transfer |

**Key Milestones:**
- Documentation delivered
- Production deployment guide delivered
- Knowledge transfer complete

### Timeline Summary

```
===============================================================================
                    PILOT DOMAIN - PROJECT TIMELINE (7 WEEKS)
===============================================================================

WEEK     1    2    3    4    5    6    7
         |    |    |    |    |    |    |
---------+----+----+----+----+----+----+

PHASE 1: DISCOVERY & DESIGN (2.0 days)
         ====
         Week 1

PHASE 2: BUILD (12.5 days)
              ===============
              Week 2-4

PHASE 3: TESTING & DEPLOYMENT (4.5 days)
                             =========
                             Week 5-6

PHASE 4: DOCUMENTATION & HANDOVER (4.75 days)
                                        ====
                                        Week 7

===============================================================================
                              KEY MILESTONES
===============================================================================

  Wk 1  - Design approved, Metrics database created
  Wk 2  - Surrogate keys implemented
  Wk 3  - DBT models repointed
  Wk 4  - Orchestration operational
  Wk 6  - Testing complete, DEV deployed
  Wk 7  - Documentation delivered, Production guide delivered

===============================================================================
```

**Total Duration:** ~7 weeks

---

## 5. Resourcing Needs

### 5.1 Snowflake Professional Services Team

| Role | FTE | Duration | Responsibilities | Required Skills & Expertise |
|------|-----|----------|------------------|----------------------------|
| **Lead Solution Architect** | 1.0 | Full engagement (7 weeks) | Solution architecture, DBT modifications, technical leadership, documentation | DBT Core, Snowflake, Data modeling, SQL, Airflow, Solution design |

### 5.2 Canva Team Requirements

| Role | Commitment | Duration | Responsibilities |
|------|------------|----------|------------------|
| **Domain SME (Prateeti/Rowena)** | 4-6 hrs/week | Full engagement | Requirements clarification, design validation, model review |
| **Technical Lead** | 2-4 hrs/week | Full engagement | Technical decisions, approvals, escalations |
| **Data Platform Team** | As needed | Full engagement | Airflow infrastructure, event triggers, database provisioning |
| **QA/Testing Resource** | 2-4 hrs/week | Weeks 6-7 | Testing execution, business validation |

### 5.3 Infrastructure Requirements

| Requirement | Owner | Timeline |
|-------------|-------|----------|
| Feature Catalog Metrics database | Platform Team | Week 1 |
| Development environment access | Platform Team | Week 1 |
| Airflow environment with event triggering | Platform Team | Week 3 |
| Access to existing Feature Catalog DBT project | Domain Team | Week 1 |
| Foundation layer event trigger availability | Platform Team | Week 3 |

---

## 6. Open Questions

| # | Question | Owner | Impact | Priority |
|---|----------|-------|--------|----------|
| 1 | Is Airflow event-driven orchestration available for V2 platform tooling? | Platform Team | May require alternative approach | High |
| 2 | Which Snowflake dev environment should be used for migration work? | Domain Team | Environment setup | High |
| 3 | When will V2X be available if event triggering not in V2? | Platform Team | Orchestration timeline | Medium |
| 4 | What is the process for DBT model changes and environment promotion? | Adrian/Helen | Workflow clarity | Medium |
| 5 | Are there any additional tables beyond the 16 that need repointing? | Domain Team | Scope validation | Medium |

---

## 7. Risks and Assumptions

### 7.1 Assumptions

| # | Assumption | Source |
|---|------------|--------|
| A1 | The high-level design for the Pilot Domain will be approved by the Architectural Working Group at Canva | Meeting requirement |
| A2 | A development environment is available and ready for use | Meeting requirement |
| A3 | All upstream requirements for event triggering from the foundation layer in Airflow are met and ready | Meeting requirement |
| A4 | Domain already has own DBT project (Feature Catalog) - not migrating from monolithic | Meeting confirmed |
| A5 | Existing feature_catalog database will be repurposed as conformed layer - no new creation needed | Meeting confirmed |
| A6 | DBT model to table relationship is one-to-one | Meeting confirmed |
| A7 | No data migration required - DBT repointing and modifications only | Meeting confirmed |
| A8 | No governance controls required | Meeting confirmed |
| A9 | Semantic views are out of scope | Meeting confirmed |
| A10 | MH effort is restricted to DEV environment only | MH effort assumption |
| A11 | Design reviews are approved in a timely fashion | MH effort assumption |
| A12 | Platform tooling is V2 (not V2X like other domains) | Meeting confirmed |
| A13 | 10% complex models do not require changes; all changes treated as medium complexity | Meeting confirmed |
| A14 | SME availability of 4-6 hours/week throughout engagement | Expected commitment |
| A15 | Cortex Code can be connected to target Snowflake environment | Development tooling |
| A16 | Activities marked as "AI Scalable" are subject to 30% effort reduction when using AI-assisted development tools | Effort calculation assumption |

### 7.2 Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | **High-level design not yet approved** - Design awaits Architectural Working Group review | High | High | Document as dependency; proceed with assumption of approval; maintain flexibility in approach |
| R2 | **Airflow event triggering not available in V2** - Platform tooling version may not support event-driven orchestration | Medium | High | Early engagement with Platform Team; identify alternative triggering approaches |
| R3 | **Platform tooling differences** - V2 vs V2X differences may impact orchestration approach | Medium | Medium | Document dependencies; work with Platform Team on compatibility |
| R4 | **DEV environment readiness** - Development environment may not be ready | Medium | High | Add assumption of DEV environment availability; early validation |
| R5 | **SME availability** - Domain SMEs unavailable for required workshops | Medium | Medium | Identify backup SMEs; flexible scheduling; document decisions |
| R6 | **Foundation layer dependencies** - Event triggers from foundation layer not ready | Medium | High | Early validation with foundation team; fallback to scheduled triggers |
| R7 | **Scope creep** - Additional tables or requirements identified during discovery | Low | Medium | Strict change control; document all additions |
| R8 | **Working group approval delays** - Design approval takes longer than expected | Medium | Medium | Parallel track preparation; document dependencies |

---

**Document History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | February 2026 | Snowflake PS | Initial draft |

---

*This Scope of Work is based on information gathered during the Pilot Domain scoping meeting held on February 12, 2026, the HLDD documentation provided by Canva, and AI-generated meeting summaries. Estimates are subject to refinement upon design approval by the Architectural Working Group.*
