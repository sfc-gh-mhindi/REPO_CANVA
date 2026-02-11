# Monetisation Domain Data Pipeline Migration Proposal

**Client:** Canva  
**Domain:** Monetisation  
**Prepared by:** Snowflake Professional Services  
**Date:** February 3, 2026  
**Version:** 1.0 (DRAFT)

---

## 1. Scope of Work

### 1.1 In-Scope Pipelines
| Pipeline | Description |
|----------|-------------|
| Merchant Fee Reporting | Gateway transaction summaries, fee calculations, payment processing metrics |
| Payout, Offers & Coupon Disputes | Payout brand earnings, coupon analytics, refund/dispute fact tables |

**Note:** Subscription Data Transformation pipeline is **out of scope** for this engagement and will be addressed in a separate workshop with Aiden Guerin.

### 1.2 Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Solution Design Document** | Architecture design for three-layer data model (Conformed, Metrics, Semantic) across three Snowflake databases |
| 2 | **Data Model Redesign** | Redesigned schemas for 14 target tables (not lift-and-shift) optimised for downstream consumption and LLM/AI readiness |
| 3 | **DBT Model Development** | Migration and rewrite of ~50 DBT models with appropriate complexity handling |
| 4 | **Historical Data Migration** | Full historical data migration to new table structures |
| 5 | **Data Quality Framework** | Migration of existing unit tests, integration tests, and data quality tests from current DBT YAML files |
| 6 | **Governance Implementation** | Data classifications, masking policies, and RBAC designs applied to new tables |
| 7 | **Orchestration Setup** | Airflow DAGs for event-based and schedule-based triggers (replacing Kubernetes jobs) |
| 8 | **Parallel Run Support** | 3-month parallel run configuration with validation framework |
| 9 | **Migration Guide** | Documentation for downstream consumers to transition from old to new models |
| 10 | **Semantic Layer** | Snowflake Semantic Views for Cortex Analyst/Intelligence AI consumption |

### 1.3 Out of Scope
- Subscription Data Transformation pipeline (separate engagement)
- Downstream consumer application changes
- metrics alerts (pending confirmation from Nicholas Prima)
- Platform team infrastructure changes
- Source system modifications

---

## 2. Effort Estimate

### 2.1 Effort Breakdown by Phase

| Phase | Activities | Estimated Effort (Days) |
|-------|-----------|-------------------------|
| **Discovery & Design** | Requirements validation, current state analysis, solution design document | 8-10 |
| **Conformed Layer Development** | Data modeling, DBT model development, initial table builds | 12-15 |
| **Metrics Layer Development** | Metrics definition with SMEs, DBT transformations, aggregation logic | 10-12 |
| **Semantic Layer Development** | Requirements discovery, semantic model design, semantic view build in Snowflake | 6-8 |
| **Data Migration** | Historical data migration scripts, validation, reconciliation | 8-10 |
| **Governance & Security** | Data classification, masking policies, RBAC implementation | 4-5 |
| **Testing & Quality** | Unit tests, integration tests, data quality test migration | 8-10 |
| **Orchestration** | Airflow DAG development, event/schedule trigger setup | 5-6 |
| **Parallel Run Support** | Dual-pipeline validation, monitoring, issue resolution | 10-12 (spread over 3 months) |
| **Documentation & Handover** | Migration guide, runbooks, knowledge transfer | 4-5 |

### 2.2 Effort Summary

| Category | Low Estimate | High Estimate |
|----------|--------------|---------------|
| **Total Effort** | 75 days | 93 days |
| **Contingency (15%)** | 11 days | 14 days |
| **Grand Total** | 86 days | 107 days |

### 2.3 Assumptions for Estimate
- DBT complexity distribution: ~20% simple, ~60% medium, ~20% complex (pending Kaihao's analysis)
- Data volume in gigabytes range (confirmed)
- Existing documentation in DBT YAML files is accurate and complete
- Metric definitions for Merchant Fee Reporting exist; others require SME collaboration
- No major schema changes to source tables during migration
- Client team available for requirements clarification and testing support

### 2.4 Basis of Estimate - Calculation Methodology

#### 2.4.1 Dimensional Assumptions

| Dimension | Assumed Value | Source |
|-----------|---------------|--------|
| Total DBT models | ~50 | Kaihao (workshop estimate) |
| Total tables | 14 | Confirmed in workshop |
| Overall complexity rating | 6-7 out of 10 | Kaihao (workshop estimate) |
| Data volume | Gigabytes | Confirmed in workshop |

#### 2.4.2 Model Distribution Across Layers

| Layer | Assumed Model Count | Rationale |
|-------|---------------------|-----------|
| Conformed Layer | ~20 models (40%) | Staging/foundation models - typically higher count, lower complexity |
| Metrics Layer | ~30 models (60%) | Aggregation/business logic - bulk of transformation work |
| Semantic Layer | N/A | Snowflake Semantic Views - not DBT models (see section 2.4.4) |

#### 2.4.3 Complexity Distribution (Assumed)

| Complexity | % of Models | Count | Effort per Model |
|------------|-------------|-------|------------------|
| Simple | 20% | ~10 | 0.25 days |
| Medium | 60% | ~30 | 0.5 days |
| Complex | 20% | ~10 | 1.0 days |

#### 2.4.4 Phase-by-Phase Calculation

**Discovery & Design (8-10 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Current state analysis | 2-3 | Review ~50 models documentation |
| Requirements workshops | 2-3 | 2-3 sessions x 1 day prep/follow-up |
| Solution design document | 3-4 | Architecture for 3-layer model |
| **Subtotal** | **8-10** | |

**Conformed Layer Development (12-15 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Data modeling (14 tables) | 4-5 | 14 tables x 0.3-0.4 days (redesign, not lift-and-shift) |
| DBT model development | 6-8 | ~18 models: (4 simple x 0.25) + (11 medium x 0.5) + (3 complex x 1.0) |
| Table builds & validation | 2-3 | DDL, initial loads, smoke testing |
| **Subtotal** | **12-15** | |

**Metrics Layer Development (10-12 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Metrics definition workshops | 2-3 | SME collaboration for undefined metrics |
| DBT model development | 7-8 | ~22 models: (4 simple x 0.25) + (13 medium x 0.5) + (5 complex x 1.0) |
| Validation & iteration | 1-2 | Business logic verification |
| **Subtotal** | **10-12** | |

**Semantic Layer Development (6-8 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Requirements discovery | 2-3 | Workshops to define AI/LLM use cases, questions to be answered, consumer needs |
| Semantic model design | 2-3 | Define dimensions, measures, relationships, synonyms, time grains |
| Semantic view build | 2-3 | Create semantic views in Snowflake, validate with Cortex Analyst/Intelligence |
| **Subtotal** | **6-8** | |

*Note: Semantic Layer uses Snowflake Semantic Views (YAML-based), not DBT models. Effort may vary based on discovery outcomes.*

**Data Migration (8-10 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Migration script development | 3-4 | 14 tables with full history |
| Data extraction & load | 2-3 | Gigabytes range - manageable volume |
| Reconciliation & validation | 3-4 | Row counts, checksums, sample verification |
| **Subtotal** | **8-10** | |

**Governance & Security (4-5 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Data classification | 1-2 | Apply existing classification framework |
| Masking policies | 1-2 | Based on existing policies |
| RBAC implementation | 1-2 | Simpler due to monorepo (per Kaihao) |
| **Subtotal** | **4-5** | |

**Testing & Quality (8-10 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Unit test migration | 3-4 | Migrate existing DBT YAML tests |
| Integration test development | 3-4 | End-to-end pipeline validation |
| Data quality test execution | 2-3 | Run and validate all tests |
| **Subtotal** | **8-10** | |

**Orchestration (5-6 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Airflow DAG design | 1-2 | Event-based + schedule-based patterns |
| DAG development | 2-3 | ~4-6 DAGs for 2 pipelines |
| Trigger configuration & testing | 1-2 | Integration with platform team |
| **Subtotal** | **5-6** | |

**Parallel Run Support (10-12 days spread over 3 months)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Initial setup & monitoring | 2-3 | Dual-pipeline configuration |
| Ongoing validation | 4-5 | Weekly checks (~1 day/week for 4-5 weeks active) |
| Issue resolution | 3-4 | Buffer for discrepancy investigation |
| **Subtotal** | **10-12** | |

**Documentation & Handover (4-5 days)**
| Activity | Days | Calculation |
|----------|------|-------------|
| Migration guide | 2 | Downstream consumer documentation |
| Runbooks | 1-2 | Operational procedures |
| Knowledge transfer | 1-2 | 2-3 sessions |
| **Subtotal** | **4-5** | |

#### 2.4.5 Estimate Sensitivity

| If This Changes... | Impact on Estimate |
|--------------------|-------------------|
| Complexity distribution shifts to 30% complex | +8-12 days |
| Model count is 70 instead of 50 | +10-15 days |
| Additional tables identified | +1-2 days per table |
| SME availability drops to 2 hrs/week | +5-8 days (waiting time) |
| Code sharing delayed by 4+ weeks | +5-10 days (rework/discovery) |

---

## 3. High-Level Execution Plan

### Phase 1: Discovery & Design (Weeks 1-2)
- Receive and analyse sample DBT models (simple, medium, complex)
- Review existing YAML documentation and Confluence pages
- Conduct SME workshops for metrics definition
- Deliver Solution Design Document for approval

### Phase 2: Foundation Build (Weeks 3-6)
- Develop Conformed Layer models and tables
- Implement data governance framework (classifications, masking, RBAC)
- Set up development and testing environments
- Begin historical data migration scripts

### Phase 3: Metrics & Semantic Layers (Weeks 7-10)
- Build Metrics Layer DBT models
- Collaborate with SMEs on metrics validation
- Develop Semantic Layer for AI consumption
- Implement orchestration (Airflow DAGs)

### Phase 4: Testing & Validation (Weeks 11-13)
- Execute unit and integration tests
- Migrate data quality tests from existing DBT YAMLs
- Perform data reconciliation between old and new models
- UAT with business stakeholders

### Phase 5: Parallel Run (Weeks 14-26)
- Deploy new pipeline alongside existing system
- Monitor data consistency between old and new pipelines
- Address any discrepancies and issues
- Support downstream consumer migration

### Phase 6: Cutover & Handover (Week 27)
- Final validation sign-off
- Decommission parallel run infrastructure
- Complete documentation handover
- Knowledge transfer sessions

```
Week:  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
       |--Discovery--|--Foundation Build--|--Metrics/Semantic--|--Testing--|--------Parallel Run--------|--Cut--|
```

**Total Duration:** ~27 weeks (including 3-month parallel run)

---

## 4. Resourcing Needs

### 4.1 Snowflake Professional Services Team

| Role | FTE | Duration | Responsibilities | Required Skills & Technology Expertise |
|------|-----|----------|------------------|----------------------------------------|
| **Lead Data Engineer** | 1.0 | Full engagement | Solution architecture, complex DBT development, technical leadership | DBT Core (advanced), Snowflake (advanced), Data modeling, SQL (advanced), Airflow, Semantic Views/Cortex Analyst, Solution design |
| **Data Engineer** | 1.0 | Weeks 3-13 | DBT model development, data migration, testing | DBT Core (intermediate-advanced), Snowflake, SQL, Python, Data migration, Testing frameworks |
| **Data Governance Specialist** | 0.5 | Weeks 5-8 | Data classification, masking policies, RBAC design | Snowflake RBAC, Data classification frameworks, Masking policies, Access control design |

### 4.2 Canva Team Requirements

| Role | Commitment | Responsibilities |
|------|------------|------------------|
| **Domain SME (Kaihao Wang)** | 4-6 hrs/week | Requirements clarification, metrics definition, model validation |
| **Technical Lead (Aiden Guerin)** | 2-4 hrs/week | Technical decisions, approvals, escalations |
| **Data Platform Team** | As needed | Airflow infrastructure, compliant code sharing mechanism, event triggers |
| **QA/Testing Resource** | 2-4 hrs/week | UAT execution, business validation |
| **Downstream Consumers** | As needed | Migration testing, feedback on new models |

### 4.3 Infrastructure Requirements
- Development Snowflake environment with three databases (Conformed, Metrics, Semantic)
- Airflow environment for orchestration development
- Access to current DBT models (via compliant sharing mechanism)
- Access to existing data quality test definitions

---

## 5. Open Questions

| # | Question | Owner | Impact |
|---|----------|-------|--------|
| 1 | What is the exact distribution of DBT model complexity (simple/medium/complex)? | Kaihao Wang | Refines effort estimate |
| 2 | Can sample DBT models be shared via compliant mechanism? When? | Vishnu/Vanessa + Platform Team | Blocks detailed design |
| 3 | Should metrics alerts be included in migration scope? | Kaihao + Nicholas Prima | Potential scope addition |
| 4 | What is the exact refresh frequency for each table (event vs scheduled)? | Kaihao Wang | Impacts orchestration design |
| 5 | Are there any metric definitions missing that require SME workshops? | Kaihao Wang | Impacts Metrics Layer timeline |
| 6 | What is the expected data volume growth during migration period? | Canva Data Platform | Impacts migration strategy |
| 7 | Will there be a model freeze during migration, or how will changes be communicated? | Kaihao + Team | Risk mitigation |
| 8 | What is the downstream consumer notification/migration process? | Aiden Guerin | Documentation requirements |
| 9 | Who are the key stakeholders for UAT sign-off? | Aiden Guerin | Testing phase planning |
| 10 | What is the rollback strategy if parallel run validation fails? | Joint decision | Risk mitigation |

---

## 6. Risks and Assumptions

### 6.1 Assumptions

| # | Assumption |
|---|------------|
| A1 | All source data is currently available in Snowflake (confirmed) |
| A2 | Data volume is in gigabytes range and manageable for full historical migration |
| A3 | DBT Core is the transformation platform (no DBT Cloud features required) |
| A4 | Existing DBT YAML files contain complete documentation for current models |
| A5 | Canva platform team will provide Airflow infrastructure and event-based triggers |
| A6 | 14 tables are native Snowflake tables (no transient or external tables) |
| A7 | Three-month parallel run is sufficient for validation and downstream migration |
| A8 | Model redesign scope is limited to structure changes; no major business logic changes |
| A9 | Compliant code sharing mechanism will be established within 2 weeks of engagement start |
| A10 | Client SMEs are available for scheduled workshops and clarifications |

### 6.2 Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | **Code sharing delays** - Compliance mechanism not established in time | Medium | High | Early engagement with Platform Team; fallback to detailed documentation review |
| R2 | **Scope creep** - Additional tables/models identified during discovery | Medium | Medium | Strict change control process; separate backlog for Phase 2 |
| R3 | **Model complexity higher than estimated** - More complex models than anticipated | Medium | High | Buffer in estimates; request complexity breakdown before engagement |
| R4 | **SME availability** - Key resources unavailable for workshops | Medium | High | Identify backup SMEs; flexible scheduling |
| R5 | **Source model changes during migration** - Bug fixes break alignment | Medium | Medium | Communication protocol established; change notification process |
| R6 | **Parallel run discrepancies** - Data mismatches difficult to reconcile | Medium | High | Clear validation criteria upfront; acceptance thresholds defined |
| R7 | **Downstream consumer migration delays** - Users slow to adopt new models | Low | Medium | Early communication; migration guide; extended parallel run if needed |
| R8 | **Governance complexity** - RBAC design more complex than monorepo suggests | Low | Medium | Early governance assessment; involve security team |
| R9 | **Semantic layer requirements unclear** - AI consumption needs not defined | Medium | Medium | Discovery workshop with Snowflake Intelligence team |
| R10 | **Subscription pipeline dependency** - Implicit dependencies with out-of-scope pipeline | Low | High | Explicit interface definition; separate engagement tracking |

---

## 7. Next Steps

1. **Kaihao Wang** - Provide DBT model complexity breakdown (simple/medium/complex counts)
2. **Kaihao Wang** - Share sample DBT models once compliant mechanism is established
3. **Vishnu/Vanessa** - Coordinate with Platform Team (Frank, Stephen) on code sharing mechanism
4. **Mazen Hindi** - Schedule follow-up workshop with Aiden Guerin for Subscription pipeline
5. **Snowflake PS** - Finalise proposal and pricing upon receipt of complexity analysis
6. **All** - Review and confirm assumptions; raise any additional questions

---

**Document Status:** DRAFT - Pending client review and complexity analysis  
**Next Review Date:** TBD (post complexity breakdown receipt)

---

*This proposal is based on information gathered during the Monetisation Domain workshop held on February 3, 2026. Estimates are subject to refinement upon receipt of additional technical details.*
