# Canva Custom SoW - Section A

## 1. Engagement Objectives and Outcomes

**Objectives:**
- Build an AI artifact that facilitates and expedites Canva's migration from monolithic DBT models and table structures to the target three-layer architecture
- Re-architect Editor Sessions into target multi-layer model (Conformed, Metrics, Semantic) to validate the migration approach
- Evaluate where AI provides most value across analysis, design, and build activities through hands-on application
- Gather evidence and learnings to inform a higher-confidence assessment on AI-enabled scale-out viability for remaining domains

**Expected Outcomes:**
- Production-ready Editor Sessions migration to three-layer star schema architecture
- Functional AI artifact trained on Canva migration patterns
- Qualitative assessment of AI effectiveness across migration activity types
- Learnings and observations to support scale-out planning for remaining domains
- Refined scope and approach for Phase 2 based on pilot learnings

---

## 2. Deliverables

**Migration:**
- Remodelled dim_editor_session table into separate data elements across Conformed and Metrics layers
- Redesigned DBT models that populate the newly modelled tables in the target architecture
- Star schema data model with separated dimensions and facts
- 1 semantic view for Snowflake Intelligence
- Daily Airflow orchestration DAG
- Solution design and data architecture documentation

**AI Artifact:**
- AI artifact trained on Product Experience domain context (dim_editor_sessions current state, existing DBT patterns, naming conventions, and transformation logic) designed to remodel data structures, redesign DBT models, and build transformations
- Optimised prompt templates for analysis, design, and build activities
- Effectiveness assessment with observations and recommendations

**Decision Support:**
- Learnings and recommendations for Phase 2

---

## 3. In-Scope Activities

**Migration Delivery:**
- Analyse existing DBT models and dim_editor_session monolithic table
- Remodel dim_editor_session into separate data elements in Conformed and Metrics layers
- Redesign and build DBT models that populate the newly modelled tables
- Create 1 semantic view for Snowflake Intelligence
- Configure daily Airflow orchestration
- Execute integration and data quality testing

**AI Artifact Development:**
- Extract common DBT patterns, naming conventions, and transformation logic from dim_editor_sessions current state
- Train AI artifact on Canva-specific migration patterns for data remodelling, DBT redesign, and build activities
- Develop optimised prompts for analysis, design, and build activities
- Validate artifact effectiveness on Editor Sessions tasks
- Document artifact capabilities, limitations, and usage guidelines

**Effectiveness Assessment:**
- Evaluate AI contribution across activity categories (analysis, design, build)
- Identify patterns that transfer well vs require customisation

---

## 4. Out-of-Scope Items

- Downstream consumer re-pointing (migration guide provided only)
- Upstream source migration (data consumed as-is)
- Governance implementation (not required per domain owner)
- Decommissioning old tables
- Deployment to UAT and Production (handled by Canva)
- Historical data migration (rebuild from source)
- Other domain migrations (Editor Sessions only)
- Full AI artifact productionisation (prototype only)

---

## 5. Assumptions & Customer Responsibilities

**Assumptions:**
- AI artifact will be developed using Product Experience domain context, including existing DBT models, table structures, naming conventions, and transformation patterns specific to this domain
- All source data currently available in Snowflake; no new ingestion required
- DBT Core (open source) is the transformation platform
- Platform team will provision databases and Airflow infrastructure
- Design reviews approved in timely fashion by the Canva team
- Cortex Code integration with Canva's Snowflake Development environment is allowed
- Access to existing DBT codebase available at engagement start
- Existing code has sufficient redundancy/patterns for artifact learning
- Scope of work is limited to Canva's Development environment

**Customer Responsibilities:**
- Grant repository access to existing DBT project and all relevant codebases
- Provide SME availability for requirements and validation
- Provision 3 Snowflake databases (product_experience_*) within the first 3 days of the engagement start date
- Provision Airflow environment for orchestration within the first week of the engagement start date
- Enable AI development tooling access to Snowflake environment at the start of the engagement
- Provide technical decisions and approvals within 2 business days
- Share existing documentation and coding standards for the Product Experience domain at the start of the engagement
- Onboard Snowflake personnel to Canva's environments prior to engagement start
- Provide administrative access to newly created databases (Conformed, Metrics, and Semantic layers)

---

## 6. Senior Solutions Architect Scope

This is an outcome-based engagement with fixed scope and deliverables as defined in this document. The Snowflake Senior Solutions Architect will deliver the specified outcomes within the agreed timeframe, focused exclusively on the outcomes and deliverables mentioned above.

Snowflake will manage the delivery approach and execution to achieve the defined outcomes. Customer collaboration is required for design reviews, approvals, and validation activities as outlined in Customer Responsibilities.

This engagement is limited to the scope defined in this document. Any work outside the defined scope, deliverables, or out-of-scope items will require a separate agreement or change order.

---

## 7. Snowflake Access

1. **Development Environment Access.** To facilitate delivery of the outcomes defined in this document, Customer will provide Snowflake personnel with access to Customer's Snowflake Development environment and DBT Core development environment. Integration of Customer's Snowflake Development environment with Cortex Code is required for AI artifact development.

2. **Non-Production Data Access.** Snowflake personnel may access non-production Customer Data for the purposes of unit testing, integration testing, and data quality testing of the migrated work.

3. **Customer Obligations.** Customer shall not request that Snowflake personnel use, or otherwise provide to such personnel, software or other code for Snowflake's systems and/or equipment which could allow Customer or a third party to access or use Snowflake systems and/or equipment (e.g., remote server services software or SSH access to a laptop).

