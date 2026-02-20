# AI-Enabled Migration Pilot - Scope of Work

**Client:** Canva  
**Engagement:** AI-Enabled Migration Pilot  
**Pipeline:** Editor Session (Product Experience Domain)  
**Prepared by:** Snowflake Professional Services  
**Date:** February 2026  
**Version:** 1.0 (DRAFT)  
**Document Status:** For Review

---

## 1. Engagement Objectives and Outcomes

### 1.1 Objectives

| # | Objective | Description |
|---|-----------|-------------|
| 1 | **Train AI Artifact** | Develop and train a Cortex Code skill on Canva's existing DBT models and table structures |
| 2 | **Validate Migration Approach** | Re-architect Editor Sessions into target multi-layer model (Conformed, Metrics, Semantic) |
| 3 | **Quantify Acceleration** | Measure time and effort reduction achieved through AI-assisted development |
| 4 | **Enable Decision** | Provide clear go/no-go decision for AI-enabled scale-out to remaining domains |

### 1.2 Expected Outcomes

| Outcome | Description |
|---------|-------------|
| **Production-Ready Migration** | Editor Sessions fully migrated to three-layer star schema architecture |
| **Trained AI Artifact** | Cortex Code skill capable of accelerating future domain migrations |
| **Quantified Acceleration** | Measured time/effort reduction with projections for remaining domains |
| **Go/No-Go Decision** | Clear recommendation with supporting data for AI-enabled scale-out |

### 1.3 Strategic Outcomes by Decision Path

| Decision | Outcome |
|----------|---------|
| **GO (>25% reduction)** | Cross-domain scaling; reuse artifacts across remaining 7 domains; projected 25-35% overall effort reduction |
| **CONDITIONAL GO (15-25%)** | Proven baseline; Phase 2 focuses on artifact refinement; second domain used for tuning |
| **NO-GO (<15%)** | Valuable learning; Editor Sessions still delivered; proceed with traditional approach |

---

## 2. Deliverables

### 2.1 Migration Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Three-Layer Architecture** | product_experience_conformed, _metrics, _semantic databases with schemas |
| 2 | **Star Schema Data Model** | Redesigned Editor Sessions with separated dimensions and facts |
| 3 | **DBT Models** | ~5 new DBT models replacing 7 existing models |
| 4 | **Semantic View** | 1 semantic view for Snowflake Intelligence queries |
| 5 | **Orchestration** | Daily Airflow DAG for Editor Sessions refresh |
| 6 | **Documentation** | Solution design, data architecture, migration guide |

### 2.2 AI Artifact Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Cortex Code Skill** | Trained skill for DBT migration tasks |
| 2 | **Pattern Library** | Documented patterns extracted from Canva codebase |
| 3 | **Prompt Templates** | Optimised prompts for analysis, design, and build activities |
| 4 | **Effectiveness Report** | Quantified acceleration metrics and recommendations |
| 5 | **Scale-Out Playbook** | Guidelines for applying artifact to remaining domains |

### 2.3 Decision Support Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | **Go/No-Go Recommendation** | Clear recommendation with supporting data |
| 2 | **Acceleration Projections** | Projected effort reduction for remaining domains |
| 3 | **Risk Assessment** | Updated risk profile based on pilot learnings |

---

## 3. In-Scope Activities

### 3.1 Migration Delivery (Editor Sessions)

| Activity | Description |
|----------|-------------|
| **Current State Analysis** | Analyse 7 existing DBT models and 1 monolithic dimension table (dim_editor_session) |
| **Star Schema Design** | Redesign into proper star schema with separated dimensions (user, device, design, platform) and session facts |
| **DBT Model Build** | Build ~5 new DBT models in three-layer architecture (30% model reduction target) |
| **Semantic Layer** | Create 1 semantic view for Snowflake Intelligence |
| **Orchestration** | Configure daily Airflow orchestration |
| **Testing** | Integration and data quality testing |

### 3.2 AI Artifact Development

| Activity | Description |
|----------|-------------|
| **Pattern Extraction** | Extract common DBT patterns, naming conventions, and transformation logic from existing codebase |
| **Skill Training** | Train Cortex Code skill on Canva-specific migration patterns |
| **Prompt Engineering** | Develop optimised prompts for analysis, design, and build activities |
| **Validation** | Test artifact effectiveness on Editor Sessions migration tasks |
| **Documentation** | Document skill capabilities, limitations, and usage guidelines |

### 3.3 Acceleration Measurement

| Metric | Measurement Approach |
|--------|---------------------|
| **Time Reduction** | Compare actual effort vs baseline estimate for each activity category |
| **Quality Impact** | Track rework cycles, defect rates, and review iterations |
| **Scalability Indicators** | Identify patterns that transfer well vs require customisation |
| **Effort Distribution** | Analyse where AI provides most/least value (analysis, design, build, testing) |

---

## 4. Out-of-Scope Items

| Item | Rationale |
|------|-----------|
| **Downstream Consumer Re-pointing** | Migration guide provided; actual re-pointing is consumer responsibility |
| **Upstream Source Migration** | Source data consumed as-is from current location |
| **Governance Implementation** | No policies or classifications required per domain owner |
| **Decommissioning Old Tables** | Separate operational activity |
| **Production Deployment** | Handled by Canva internal team |
| **Historical Data Migration** | Not required - rebuild from source |
| **Other Domain Migrations** | Focus exclusively on Editor Sessions for pilot |
| **Full AI Skill Productionisation** | Pilot produces prototype; full productionisation is Phase 2 |

---

## 5. Assumptions & Customer Responsibilities

### 5.1 Assumptions

| # | Assumption |
|---|------------|
| A1 | All source data is currently available in Snowflake; no new ingestion required |
| A2 | Total DBT models in scope is 7 |
| A3 | DBT Core (open source) is the transformation platform |
| A4 | Platform team will provision databases and Airflow infrastructure |
| A5 | Design reviews are approved in a timely fashion |
| A6 | Cortex Code can be connected to Canva's Snowflake environment |
| A7 | Access to existing DBT codebase available at engagement start |
| A8 | Existing code has sufficient redundancy/patterns for skill learning |
| A9 | Snowflake Cortex Code AI-assisted development is used |

### 5.2 Customer Responsibilities

| # | Responsibility |
|---|----------------|
| C1 | Grant repository access to existing DBT project |
| C2 | Provide SME availability for requirements and validation |
| C3 | Provision Snowflake databases (product_experience_conformed, _metrics, _semantic) |
| C4 | Provision Airflow environment for orchestration |
| C5 | Enable Cortex Code access to Snowflake environment |
| C6 | Provide technical decisions and approvals |
| C7 | Share existing documentation and coding standards |

### 5.3 Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | **Editor Sessions not representative** - Smaller pipeline may not fully represent larger domains | Medium | Medium | Document transferability limitations; plan second domain validation |
| R2 | **AI effectiveness depends on code structure** - Existing DBT code may not support skill learning | Medium | High | Early codebase analysis; adjust expectations if patterns insufficient |
| R3 | **Codebase access delays** - Early access required for calibration | Medium | High | Escalate access requirements immediately |
| R4 | **Column classification complexity** - 50+ columns difficult to classify | Medium | Medium | Early SME engagement; iterative design approach |
| R5 | **Skill overfitting** - AI artifact too specific to Editor Sessions | Medium | Medium | Design skill with generalisation in mind |

---

## 6. Investment

| Currency | Amount |
|----------|--------|
| **AUD** | $112,840 |
| **USD** | $71,879 |

**Total Effort:** 35 days

---

**Document History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | February 2026 | Snowflake PS | Initial draft |
