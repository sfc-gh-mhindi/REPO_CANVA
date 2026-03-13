# Cumulative Dependencies and Assumptions Register

**Engagement:** AI-Enabled Migration Pilot - Editor Sessions (dim_editor_session)  
**Date:** March 2026  
**Purpose:** Consolidated view of all dependencies and assumptions from customer-facing and internal SOW documents

---

## Dependencies

| # | Dependency | Owner | Timeline | Origin |
|---|------------|-------|----------|--------|
| D1 | Onboard Snowflake personnel to Canva's environments | Canva | Prior to engagement commencement | Customer SOW (A7) |
| D2 | Access to existing DBT codebase | Canva | At engagement commencement (Day 1) | Customer SOW (A7), Internal SOW |
| D3 | Provision 3 Snowflake databases (product_experience_conformed, product_experience_metrics, product_experience_semantic) | Canva Platform Team | Within 3 business days of engagement commencement | Customer SOW (A7), Internal SOW |
| D4 | Provision Airflow environment for orchestration | Canva Platform Team | Within 5 business days of engagement commencement | Customer SOW (A7), Internal SOW |
| D5 | Enable AI development tooling (Cortex Code) access to Snowflake environment | Canva | At engagement commencement | Customer SOW (A7), Internal SOW |
| D6 | Technical decisions and approvals | Canva Technical Lead | Within 2 business days of request | Customer SOW (A7), Internal SOW |
| D7 | Share existing documentation and coding standards for Product Experience domain | Canva Domain SME | At engagement commencement | Customer SOW (A7), Internal SOW |
| D8 | Canva team approves design reviews within agreed timelines | Canva | Per agreed schedule | Customer SOW (A7) |
| D9 | Access to existing DBT models (code sharing) | Owen Yan | Week 1 | Internal SOW |
| D10 | Documentation and model specifications | Owen Yan | Week 1 | Internal SOW |
| D11 | Development environment access | Canva Platform Team | Week 1 | Internal SOW |

---

## Customer Responsibilities

| # | Responsibility | Origin |
|---|----------------|--------|
| CR1 | Promotion to any environment aside from the development Snowflake environment | Customer SOW (A8) |
| CR2 | Grant repository access to existing DBT project and all relevant codebases | Customer SOW (A8), Internal SOW |
| CR3 | Provide SME availability for requirements and validation | Customer SOW (A8), Internal SOW |
| CR4 | Provide administrative access to newly created databases (Conformed, Metrics, and Semantic layers) | Customer SOW (A8), Internal SOW |
| CR5 | Meet/deliver the dependencies as outlined in Section A7 | Customer SOW (A8) |
| CR6 | Onboard Snowflake personnel to Canva's environments prior to engagement start | Internal SOW |
| CR7 | Provide technical decisions and approvals within 2 business days | Internal SOW |
| CR8 | Share existing documentation and coding standards at engagement start | Internal SOW |

---

## Snowflake Assumptions

| # | Assumption | Impact if Invalid | Origin |
|---|------------|-------------------|--------|
| SA1 | Snowflake will work exclusively in the development Snowflake environment | Scope change required | Customer SOW (A6) |
| SA2 | AI artifact is experimental; effectiveness may vary and is not guaranteed | Expectation management | Customer SOW (A6) |
| SA3 | AI artifact will be developed using Product Experience domain context (existing DBT models, table structures, naming conventions, transformation patterns) | May impact artifact quality | Customer SOW (A6), Internal SOW |
| SA4 | All source data currently available in Snowflake; no new ingestion required | Additional scope if invalid | Customer SOW (A6), Internal SOW |
| SA5 | DBT Core (open source) is the transformation platform | Platform change impact | Customer SOW (A6), Internal SOW |
| SA6 | Cortex Code integration with Canva's Snowflake development environment is permitted | Blocks AI artifact development | Customer SOW (A6), Internal SOW |
| SA7 | Existing code has sufficient patterns for artifact learning | May impact AI effectiveness | Customer SOW (A6), Internal SOW |
| SA8 | 'Production-quality' Editor Sessions migration refers to code/architecture suitable for production deployment, not actual deployment to production | Expectation alignment | Customer SOW (A6) |
| SA9 | Snowflake will manage delivery approach and execution; Canva collaboration required for design reviews, approvals, and validation | Delivery model clarity | Customer SOW (A6) |
| SA10 | Where approvals not provided within stated timeframes, Snowflake may proceed based on reasonable technical assumptions | Risk mitigation | Customer SOW (A7) |

---

## Internal Assumptions (Not in Customer SOW)

| # | Assumption | Value | Source | Impact |
|---|------------|-------|--------|--------|
| IA1 | Total DBT models in scope (current state) | 7 | PDF documentation | Confirmed |
| IA2 | DBT complexity rating | 14% simple, 57% medium, 29% complex (1 simple, 4 medium, 2 complex) | PDF analysis | Effort calculation |
| IA3 | All target tables are native Snowflake tables | Yes | Meeting confirmed | Architecture |
| IA4 | Platform team will provision databases and Airflow infrastructure | Yes | Meeting confirmed | Dependencies |
| IA5 | SME availability | 4-6 hours/week | Expected commitment | Schedule risk |
| IA6 | No major changes to source models during migration period | Standard assumption | | Stability |
| IA7 | Design reviews are approved in a timely fashion | Standard assumption | MH effort assumption | Schedule |
| IA8 | Deployment to UAT and production environments is not included | MH effort scope | Meeting confirmed | Scope clarity |
| IA9 | Target 30% reduction in model count through consolidation | ~5 models (70% of current) | Standard redesign assumption | Efficiency target |
| IA10 | Access to source data for business transformations is available | Required | | Development |
| IA11 | Data sources and tables from upstream dependencies are available | Required | | Development |
| IA12 | Activities marked as "AI Scalable" are subject to 30% effort reduction | Effort calculation basis | | Estimate accuracy |
| IA13 | Access to personnel with source data knowledge for target state model design | Required | | Analysis quality |
| IA14 | One semantic view for the new star schema will be created | 1 view | Meeting confirmed | Deliverable |

---

## Snowflake Access

| # | Access Item | Granted | Origin |
|---|-------------|---------|--------|
| ACC1 | Customer's Snowflake Service account (Non-Production) | Yes | Customer SOW (D2) |
| ACC2 | Customer's Snowflake Service account (Production) | No | Customer SOW (D2) |
| ACC3 | Customer Data | Yes | Customer SOW (D2) |
| ACC4 | Applications for project management or collaboration (email, Jira, Slack, etc.) | Yes | Customer SOW (D2) |
| ACC5 | Read-only access to External Data Applications | Yes | Customer SOW (D2) |

---

## Risks (Internal)

| # | Risk | Likelihood | Impact | Mitigation | Origin |
|---|------|------------|--------|------------|--------|
| R1 | Column classification complexity - 50+ columns difficult to classify as dimension vs fact | Medium | Medium | Early SME engagement; iterative design approach; clear classification criteria | Internal SOW |
| R2 | Code sharing delays - Access to existing DBT models not established in time | Medium | High | Early engagement with Platform Team; fallback to detailed documentation review | Internal SOW |
| R3 | Scope creep - Additional columns or models identified during discovery | Medium | Medium | Strict change control; document all additions; separate backlog for Phase 2 | Internal SOW |
| R4 | SME availability - Domain SMEs unavailable for required workshops | Medium | High | Identify backup SMEs; flexible scheduling; document decisions | Internal SOW |
| R5 | Star schema design complexity - More complex than anticipated | Medium | Medium | Early design workshops; iterative approach | Internal SOW |
| R6 | Source model changes during migration - Bug fixes break alignment | Low | Medium | Communication protocol; change notification process; weekly sync | Internal SOW |
| R7 | Platform team capacity - Infrastructure provisioning delays | Low | High | Early engagement; clear timeline commitments; escalation path | Internal SOW |
| R8 | Semantic layer requirements unclear - Business questions not fully defined | Medium | Medium | Use questions from PDF as baseline; iterative refinement | Internal SOW |

---

## Open Questions (Internal)

| # | Question | Owner | Impact | Priority | Origin |
|---|----------|-------|--------|----------|--------|
| OQ1 | Can detailed documentation on existing DBT models be shared? | Owen Yan | Blocks detailed analysis phase | High | Internal SOW |
| OQ2 | What are the specific metric definitions for the semantic layer? | Owen Yan | Impacts semantic layer effort | High | Internal SOW |
| OQ3 | Are there additional business questions beyond those listed in the PDF? | Owen Yan | May expand semantic layer scope | Medium | Internal SOW |
| OQ4 | What is the expected data volume for dim_editor_session? | Owen Yan | Impacts testing approach | Medium | Internal SOW |
| OQ5 | Are there downstream consumers that need to be notified of migration? | Owen Yan | Documentation scope | Medium | Internal SOW |
| OQ6 | Will views mimicking old table signatures be required for backward compatibility? | Technical Lead | Additional development | Medium | Internal SOW |

---

## Document References

| Document | Type | Location |
|----------|------|----------|
| 20260227 Canva Q518360 Capacity Conv - Data Platform Modernisation POC Phase 1.pdf | Customer-Facing SOW | 5-DimEditorSession Pilot/SoW/ |
| ProductExperience_Domain_Scope_of_Work_INTERNAL.md | Internal SOW | 4-DataPipelinePrioritisation/InternalSoWs/SoWs/ |

---

*Last Updated: March 2026*
