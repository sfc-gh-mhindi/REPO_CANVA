---
name: canva-dbt-monolith-migration
description: "**[REQUIRED]** Canva Future-Ready Data Platform migration skill. Use for ALL requests to: migrate Canva DBT models, refactor DBT monolith, decompose DBT to domains, modernize DBT architecture, create domain-owned DBT projects. DO NOT attempt DBT migration manually - invoke this skill first."
---

# Canva DBT Monolith to Domain Migration

Migrate Canva's monolithic DBT projects to federated domain-owned projects with 3-layer architecture as part of the **Canva Future-Ready Data Platform** initiative.

## Migration Philosophy

**This skill does NOT refactor in place.** It creates a completely new architecture.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ CURRENT STATE (Input)                                                       │
│  • Legacy target tables (the tables you want to migrate away from)          │
│  • Existing DBT project (contains the business logic feeding those tables)  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ ANALYSIS                                                                    │
│  1. Analyze legacy tables → understand entities, relationships, metrics     │
│  2. Trace UPSTREAM in DBT → find all models feeding into legacy tables      │
│  3. Extract business logic → joins, calculations, aggregations              │
│  ⚠️  SMART SCOPING: Only models in the upstream lineage are analyzed        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ NEW STATE (Output)                                                          │
│  • NEW tables: cnf_* (Conformed) → dim_*/fact_* (Metrics) → sv_* (Semantic) │
│  • NEW DBT project: replicates behavior but writes to new architecture      │
│  • Legacy tables become DEPRECATED                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key concept:** The input tables are the LEGACY STATE you're migrating FROM, not the target.

## Setup

**Load these references:**
| Document | When |
|----------|------|
| `migration_rules.md` | Always |
| `dbt_best_practices.md` | Always |
| `output_specification.md` | Before generating |
| `domains/{domain}.md` | After domain selection |

## Supported Domains

| Code | Domain | Owns |
|------|--------|------|
| `pex` | Product Experience | User engagement, feature usage |
| `mon` | Monetisation | Revenue, billing, subscriptions |
| `mkt` | Marketing | Campaigns, attribution |
| `it` | IT | Infrastructure, systems |
| `prt` | Print | Fulfillment, production |
| `plt` | Pilot | Experiments, A/B tests |

## Output Folder Structure

**MANDATORY:** Create this folder structure at the output location:

```
{output_location}/
├── Documents/
│   ├── Designs/              # Design proposals and architecture docs
│   │   └── design_proposal.md
│   ├── Data Dictionary/      # Column-level documentation
│   ├── Lineage/              # Data flow documentation
│   └── Migration Reports/    # Migration summaries
│
├── Transformation/
│   └── {domain}_transform/   # Complete DBT project
│       ├── dbt_project.yml
│       ├── packages.yml
│       ├── models/
│       │   ├── staging/
│       │   ├── conformed/
│       │   └── metrics/
│       ├── macros/
│       └── tests/
│
└── Data Architecture/
    ├── Conformed Layer/      # DDL for cnf_* tables
    ├── Metrics Layer/        # DDL for dim_* and fact_* tables
    ├── Semantic Layer/       # Semantic view YAML + DDL (NOT in DBT project)
    └── Migration Scripts/    # Data migration scripts (optional)
```

## Target Architecture

**Each layer is a separate database:**

```
{DOMAIN}_SEMANTIC DB     sv_*         AI-ready views for Snowflake Intelligence
        ↑
{DOMAIN}_METRICS DB      dim_*/fact_* Star schema for analytics
        ↑
{DOMAIN}_CONFORMED DB    cnf_*        Cleansed, standardized entities
        ↑
SOURCE DB                {{ source() }} Raw tables (never direct access)
```

**Default naming:**
| Layer | Default Database Name | Default Schema |
|-------|----------------------|----------------|
| Conformed | `{DOMAIN}_CONFORMED` | `MAIN` |
| Metrics | `{DOMAIN}_METRICS` | `MAIN` |
| Semantic | `{DOMAIN}_SEMANTIC` | `MAIN` |

## Workflow

```
INTAKE → DISCOVERY → ANALYSIS → DESIGN → MACROS → GENERATE → VALIDATE
  ✋                              ✋                            ✋
```

---

### Step 1: Intake ✋

**Goal:** Gather requirements, identify migration scope, load domain rules, create output structure.

**Ask user for:**
1. Target domain (pex | mon | mkt | it | prt | plt)
2. **Legacy target tables** - The CURRENT tables to migrate away from:
   - DDL files defining structure, OR
   - Database/schema to DESCRIBE, OR
   - Table names to analyze
   - *(These tables represent the CURRENT STATE - they will be replaced by the new architecture)*
3. **Existing DBT project** - Path to the DBT project containing models that feed the legacy tables
4. Output location
5. **Snowflake execution context** (or accept defaults):

```
Snowflake execution context (press Enter for defaults):

1. Role:      [SYSADMIN]
2. Warehouse: [COMPUTE_WH]
```

6. **Database names for each layer** (or accept defaults):

```
Target database names (press Enter for defaults):

1. Conformed Layer Database: [{DOMAIN}_CONFORMED]
2. Metrics Layer Database:   [{DOMAIN}_METRICS]
3. Semantic Layer Database:  [{DOMAIN}_SEMANTIC]
4. Source Database:          [RAW_DB]

Schema name for all layers:  [MAIN]
```

**Then:**
1. **Create** output folder structure (see "Output Folder Structure" above)
2. **Load** `domains/{domain}.md`
3. **Store** execution context:
   - `execution_role`: User input or `SYSADMIN`
   - `execution_warehouse`: User input or `COMPUTE_WH`
4. **Store** database configuration:
   - `conformed_database`: User input or `{DOMAIN}_CONFORMED`
   - `metrics_database`: User input or `{DOMAIN}_METRICS`
   - `semantic_database`: User input or `{DOMAIN}_SEMANTIC`
   - `source_database`: User input or `RAW_DB`
   - `default_schema`: `MAIN`
5. **Ask:** "Any overrides to default rules?" (tier thresholds, etc.)
5. Confirm scope before proceeding

---

### Step 2: Discovery

**Goal:** Trace upstream lineage from legacy tables to identify migration scope.

**⚠️ SMART SCOPING:** Do NOT analyze the entire DBT project. Only analyze models in the upstream lineage of the legacy target tables.

**Actions:**
1. **Identify terminal models** - Find DBT models that write to the legacy target tables
2. **Trace upstream** - Recursively find all models referenced via `{{ ref() }}`
3. **Identify sources** - Extract all `{{ source() }}` references (raw tables)
4. **Build scoped lineage** - Create dependency graph containing ONLY:
   - Terminal models (write to legacy tables)
   - All upstream models (transitively referenced)
   - Source definitions
5. **Exclude out-of-scope models** - Models not in the upstream lineage are IGNORED

**Lineage Direction:**
```
Raw Sources → Staging → Intermediate → ... → Terminal Models → Legacy Tables
     ↑                                              ↑               ↑
     └──────────── TRACE UPSTREAM ──────────────────┘               │
                                                                    │
                                              (Current state - to be deprecated)
```

**Output:** 
- Scoped dependency graph (only in-scope models)
- Source inventory
- Count: "{X} models in scope out of {Y} total models in DBT project"

---

### Step 3: Analysis

**Goal:** Analyze IN-SCOPE models to understand business logic and detect optimization opportunities.

**Reference:** `redundancy_patterns.md`

**Analyze (within scoped models only):**

| Analysis Type | Purpose |
|---------------|--------|
| **Business logic extraction** | Understand what transformations feed the legacy tables |
| **Entity identification** | What entities/concepts do the legacy tables represent? |
| **Metric identification** | What calculations/aggregations are performed? |
| **Redundancy detection** | `*_v1`, `*_v2`, overlapping staging, repeated logic |
| **Anti-pattern detection** | Hardcoded refs, layer violations, metrics in dims |

**Map legacy tables to new architecture:**
| Legacy Table Type | Maps To New Architecture |
|-------------------|-------------------------|
| Entity/master data | cnf_* → dim_* |
| Transaction/event data | cnf_* → fact_* |
| Aggregated metrics | Absorbed into dim_*/fact_* |
| Report tables | Replaced by sv_* semantic views |

**Output:** Analysis report with:
- Business logic inventory
- Entity-to-layer mapping
- Consolidation opportunities

---

### Step 4: Design ✋

**Goal:** Propose target architecture and get approval.

**Reference:** `dbt_best_practices.md`

**4.1 Gather Semantic View Requirements**

**Ask user:**
```
To design the semantic layer, please answer (or skip for defaults):

1. Who will query this data?
   (e.g., Product managers, Data analysts, Executives, Data scientists)

2. What are the top 5-10 business questions they need to answer?
   (e.g., "What is our customer retention rate?", "Which products are underperforming?")

3. What self-service analytics do you want to enable?
   (e.g., Customer segmentation, Product performance, Revenue analysis)

Reply with answers, or "skip" to use default assumptions.
```

**If user skips or no response:** Make assumptions based on:
- Fact tables created (one semantic view per major fact)
- Existing report/analytics models (what questions they answered)
- Domain patterns from `domains/{domain}.md`

**Document all assumptions in the design proposal.**

**4.2 Design Architecture**

1. **Conformed layer** - One model per entity, define grain and key
2. **Dimensions** - SCD type, surrogate key, attributes only
3. **Facts** - Grain, FKs to dims, measures only
4. **Semantic views** - Based on user requirements or documented assumptions
5. **Macros** - Extracted repeated logic

**Generate design document:** Create `{output_location}/Documents/Designs/design_proposal.md`:

```markdown
# Migration Design Proposal: {Domain} Domain

## Executive Summary
- Legacy tables to migrate: {count}
- DBT models in scope: {count} (out of {total} in project)
- Target models proposed: {count}
- Estimated reduction: {pct}%

## Migration Scope

### Legacy Tables (Current State - To Be Deprecated)
| Legacy Table | Type | New Architecture Target |
|--------------|------|------------------------|
| {table_name} | Entity/Transaction/Report | cnf_* / dim_* / fact_* / sv_* |

### In-Scope DBT Models
| Model | Type | Feeds Into |
|-------|------|------------|
| {model_name} | staging/intermediate/mart | {legacy_table} |

### Out-of-Scope (Not Analyzed)
{X} models in DBT project are not in the upstream lineage of the legacy tables and were excluded.

## Analysis Findings

### Redundant Models Identified
| Group | Current Models | Consolidate To | Reason |
|-------|----------------|----------------|--------|

### Redundant Logic Identified  
| Pattern | Occurrences | Extract To |
|---------|-------------|------------|

### Anti-Patterns Found
| Type | Count | Examples |
|------|-------|----------|

## Proposed Architecture

### Conformed Layer
| Model | Sources | Grain | Natural Key |
|-------|---------|-------|-------------|

### Dimensions
| Model | Source | SCD Type | Key Attributes |
|-------|--------|----------|----------------|

### Facts
| Model | Grain | Foreign Keys | Measures |
|-------|-------|--------------|----------|

### Semantic Views
| View | Purpose | Base Tables |
|------|---------|-------------|

### Semantic View Rationale
| Decision | Rationale | Source |
|----------|-----------|--------|
| Number of views | {reason} | {User input / Assumption} |
| View groupings | {reason} | {User input / Assumption} |
| Measures selected | {reason} | {User input / Assumption} |
| Target users | {users} | {User input / Assumption} |

**Assumptions made (if any):**
- {assumption 1}
- {assumption 2}

### Macros
| Macro | Category | Replaces |
|-------|----------|----------|

## Consolidation Summary
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total models | {n} | {n} | -{pct}% |
| Staging models | {n} | {n} | |
| Lines of SQL | {n} | {n} | -{pct}% |

## Breaking Changes
| Change | Impact | Migration Path |
|--------|--------|----------------|

## Next Steps
1. Review and approve this design
2. Generate DBT project
3. Validate compilation
4. Optional: Generate migration scripts
```

**⚠️ MANDATORY CHECKPOINT**

```
Design document generated: {output_location}/Documents/Designs/design_proposal.md

Please review the design document and reply:
- "approved" to proceed with code generation
- Or specify changes needed
```

**DO NOT PROCEED without explicit approval.**

---

### Step 5: Macros

**Goal:** Create macro library for extracted logic.

**Reference:** `dbt_best_practices.md` for templates

**Standard macros:**
| Category | Macros |
|----------|--------|
| Tier logic | `calculate_customer_tier`, `calculate_order_tier` |
| Date helpers | `fiscal_year`, `fiscal_quarter` |
| Margins | `gross_margin`, `margin_pct` |

Generate macros with:
- Docstring with args and example
- Configurable thresholds via `var()`
- Domain-specific defaults from `domains/{domain}.md`

**Output location:** `{output_location}/Transformation/{domain}_transform/macros/`

---

### Step 6: Generate

**Goal:** Create complete DBT project and data architecture artifacts.

**Reference:** `output_specification.md` for formats

**Generate in Transformation folder:**
```
{output_location}/Transformation/{domain}_transform/
├── dbt_project.yml
├── packages.yml
├── models/
│   ├── staging/schema.yml    # Source definitions
│   ├── conformed/            # cnf_*.sql + schema.yml
│   └── metrics/
│       ├── dimensions/       # dim_*.sql + schema.yml
│       └── facts/            # fact_*.sql + schema.yml
├── macros/                   # Extracted logic
└── tests/custom/
```

**NOTE:** Semantic views are NOT part of DBT project - they go in Data Architecture/

**Generate in Data Architecture folder:**

**IMPORTANT:** DDL files are standalone SQL, NOT DBT. Each layer has its own database.

**DDL Structure:**
1. **First:** Create DATABASE and SCHEMA (if not exists)
2. **Then:** Create tables/views within that database

**Use database names from Intake step** (user-provided or defaults):
- Conformed: `{conformed_database}` (default: `{DOMAIN}_CONFORMED`)
- Metrics: `{metrics_database}` (default: `{DOMAIN}_METRICS`)
- Semantic: `{semantic_database}` (default: `{DOMAIN}_SEMANTIC`)

```
{output_location}/Data Architecture/
├── Conformed Layer/
│   └── {domain}_conformed_ddl.sql   # CREATE DATABASE, SCHEMA, then cnf_* tables
├── Metrics Layer/
│   └── {domain}_metrics_ddl.sql     # CREATE DATABASE, SCHEMA, then dim_*/fact_* tables
├── Semantic Layer/
│   ├── {domain}_semantic_ddl.sql    # CREATE DATABASE, SCHEMA, then semantic views
│   └── sv_*.yaml                    # Semantic view YAML definitions
└── Migration Scripts/
    └── {domain}_migration.sql       # Data migration (generated in Step 7)
```

**DDL Template Pattern:**
```sql
-- ==============================================================================
-- {LAYER} LAYER DDL
-- Database: {database_name}
-- Schema: MAIN
-- ==============================================================================

-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS {database_name};

-- Create schema
CREATE SCHEMA IF NOT EXISTS {database_name}.MAIN;

-- Create tables
CREATE OR REPLACE TABLE {database_name}.MAIN.{table_name} (
    ...
);
```

**Generate in Documents folder:**
```
{output_location}/Documents/
├── Designs/
│   └── design_proposal.md    # Already created in Step 4
├── Data Dictionary/
│   ├── conformed_dictionary.md
│   ├── metrics_dictionary.md
│   └── semantic_dictionary.md
├── Lineage/
│   └── data_lineage.md
└── Migration Reports/
    └── migration_report.md
```

**For each model:**
- SQL with config block, CTEs, proper refs
- Schema entry with description, columns, tests

**Required tests:** See `migration_rules.md` for requirements per model type.

---

### Step 7: Validate ✋

**Goal:** Ensure project compiles and is complete.

**Actions:**
1. Run `dbt compile` from `Transformation/{domain}_transform/` - fix errors until successful
2. Run `dbt test` if connected to Snowflake
3. Verify all folders populated:
   - Documents/ (4 subfolders with content)
   - Transformation/ (complete DBT project)
   - Data Architecture/ (3 layer DDLs)

**Present validation results:**
- Compilation status
- File counts by folder
- Deliverables location

**Ask:** "Would you like migration scripts to populate the new tables?"

If yes, generate in `{output_location}/Data Architecture/Migration Scripts/migration_scripts.sql`

---

## Key Principles

### ALWAYS
- Use `{{ source() }}` for raw tables
- Use `{{ ref() }}` for model references
- Apply naming conventions (cnf_, dim_, fact_, sv_)
- Include tests for PKs (unique + not_null) and FKs (relationships)
- Document grain for fact tables
- Generate surrogate keys for dimensions

### NEVER
- Hardcode database/schema names
- Put dimension attributes in fact tables
- Put aggregated metrics in dimension tables
- Skip design approval checkpoint
- Maintain legacy table structures

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| Source not found | Add to schema.yml sources |
| Model not found | Check ref() spelling |
| unique test failed | Review grain, add deduplication |
| relationships failed | Check join logic, orphan FKs |
