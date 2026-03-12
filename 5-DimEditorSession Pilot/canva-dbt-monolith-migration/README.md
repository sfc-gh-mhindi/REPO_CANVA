# DBT Monolith Migration Skill

Migrate monolithic DBT projects to federated, domain-owned projects with a 3-layer architecture (Conformed → Metrics → Semantic).

---

## What This Skill Does

**This skill does NOT refactor DBT in place.** It creates a completely NEW architecture.

```
┌─────────────────────────────────────────────────────────────────────┐
│ CURRENT STATE (Your Input)                                          │
│  • Legacy target tables (the tables you want to migrate away from)  │
│  • Existing DBT project (the logic feeding those tables)            │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│ NEW STATE (Skill Output)                                            │
│  • NEW tables: cnf_* → dim_*/fact_* → sv_*                          │
│  • NEW DBT project writing to the new architecture                  │
│  • Legacy tables become DEPRECATED                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Smart Scoping

If your DBT project has 5000 models but you only provide 5 legacy tables, the skill will:
1. **Trace upstream** from those 5 tables
2. **Only analyze** models in that lineage path
3. **Ignore** models unrelated to your 5 tables

---

## Quick Start

**Invoke the skill:**
```
$dbt-monolith-migration
```
Or describe your task: *"Migrate my DBT models to the PEX domain"*

---

## What You'll Need

Before starting, have the following ready:

| Input | Description | Example |
|-------|-------------|---------|
| **Target Domain** | Which domain owns this data | `pex`, `mon`, `mkt`, `it`, `prt`, `plt` |
| **Legacy Target Tables** | Tables to migrate AWAY FROM (current state) | DDL files or `ANALYTICS_DB.CUSTOMERS` |
| **Existing DBT Project** | Path to DBT project feeding those tables | `/path/to/transform/models/` |
| **Output Location** | Where to generate the new project | `/path/to/output/` |

---

## Workflow Overview

```
INTAKE → DISCOVERY → ANALYSIS → DESIGN → MACROS → GENERATE → VALIDATE
  ✋                              ✋                            ✋
```

**✋ = User checkpoint (requires your input)**

---

## User Prompts

### Step 1: Intake ✋

You'll be asked for:

**1. Basic Requirements**
- Target domain (pex | mon | mkt | it | prt | plt)
- **Legacy target tables** - The CURRENT tables to migrate away from
- **Existing DBT project** - Path to DBT project feeding those tables
- Output location

**2. Snowflake Execution Context**
```
Snowflake execution context (press Enter for defaults):

1. Role:      [SYSADMIN]
2. Warehouse: [COMPUTE_WH]
```

**3. Database Names**
```
Target database names (press Enter for defaults):

1. Conformed Layer Database: [{DOMAIN}_CONFORMED]
2. Metrics Layer Database:   [{DOMAIN}_METRICS]
3. Semantic Layer Database:  [{DOMAIN}_SEMANTIC]
4. Source Database:          [RAW_DB]

Schema name for all layers:  [MAIN]
```

**4. Rule Overrides**
> "Any overrides to default rules?" (tier thresholds, fiscal year start, etc.)

---

### Step 2: Discovery (Smart Scoping)

*Automated - no user input required*

The skill will:
1. **Identify terminal models** - Find DBT models writing to your legacy tables
2. **Trace upstream** - Recursively find all referenced models
3. **Scope the analysis** - Only models in the upstream lineage are analyzed
4. **Report scope**: *"{X} models in scope out of {Y} total models"*

```
Raw Sources → Staging → Intermediate → ... → Terminal Models → Legacy Tables
     ↑                                              ↑               ↑
     └──────────── TRACE UPSTREAM ──────────────────┘               │
                                                                    │
                                      (Current state - to be deprecated)
```

---

### Step 3: Analysis

*Automated - no user input required*

Within the scoped models, the skill will:
- Extract business logic (joins, calculations, aggregations)
- Identify entities and metrics
- Detect redundancy and anti-patterns
- Map legacy tables to new architecture layers

---

### Step 4: Design ✋

**1. Semantic View Requirements**
```
To design the semantic layer, please answer (or skip for defaults):

1. Who will query this data?
2. What are the top 5-10 business questions they need to answer?
3. What self-service analytics do you want to enable?

Reply with answers, or "skip" to use default assumptions.
```

**2. Design Approval (MANDATORY)**

A design document will be generated showing:
- Legacy tables and their new architecture targets
- In-scope vs out-of-scope models
- Proposed cnf_*, dim_*, fact_*, sv_* tables

```
Design document generated: {output}/Documents/Designs/design_proposal.md

Please review the design document and reply:
- "approved" to proceed with code generation
- Or specify changes needed
```

---

### Steps 5-6: Macros & Generate

*Automated - no user input required*

The skill generates:
- Complete DBT project (models, macros, tests, schema.yml)
- DDL scripts for all three layers (each layer = separate database)
- Documentation (data dictionary, lineage, migration report)

---

### Step 7: Validate ✋

After generation completes:
```
Would you like migration scripts to populate the new tables?
```

---

## Output Structure

```
{output_location}/
├── Documents/
│   ├── Designs/              # Design proposal
│   ├── Data Dictionary/      # Column-level docs
│   ├── Lineage/              # Data flow docs (Mermaid diagrams)
│   └── Migration Reports/    # Summary
│
├── Transformation/
│   └── {domain}_transform/   # Complete DBT project
│       ├── dbt_project.yml
│       ├── packages.yml
│       ├── models/
│       ├── macros/
│       └── tests/
│
└── Data Architecture/
    ├── Conformed Layer/      # DDL: CREATE DATABASE, tables
    ├── Metrics Layer/        # DDL: dims and facts
    ├── Semantic Layer/       # DDL + YAML definitions
    └── Migration Scripts/    # Data migration SQL
```

---

## Target Architecture

Each layer is a **separate database**:

```
{DOMAIN}_SEMANTIC     sv_*         → Snowflake Intelligence
        ↑
{DOMAIN}_METRICS      dim_*/fact_* → Star schema analytics
        ↑
{DOMAIN}_CONFORMED    cnf_*        → Cleansed entities
        ↑
SOURCE DB             raw tables   → Never direct access
```

| Layer | Default Database | Default Schema |
|-------|------------------|----------------|
| Conformed | `{DOMAIN}_CONFORMED` | `MAIN` |
| Metrics | `{DOMAIN}_METRICS` | `MAIN` |
| Semantic | `{DOMAIN}_SEMANTIC` | `MAIN` |

---

## Supported Domains

| Code | Domain | Owns |
|------|--------|------|
| `pex` | Product Experience | User engagement, feature usage |
| `mon` | Monetisation | Revenue, billing, subscriptions |
| `mkt` | Marketing | Campaigns, attribution |
| `it` | IT | Infrastructure, systems |
| `prt` | Print | Fulfillment, production |
| `plt` | Pilot | Experiments, A/B tests |

---

## Example Session

```
User: I want to migrate our customer analytics tables to the PEX domain

Skill: Great! Let me gather some information:

1. Target domain: pex
2. Legacy target tables (tables to migrate away from):
   - ANALYTICS_DB.CUSTOMERS
   - ANALYTICS_DB.CUSTOMER_METRICS
   - ANALYTICS_DB.ORDERS_SUMMARY
3. Existing DBT project path: /Users/me/projects/transform/
4. Output location: /Users/me/projects/pex_migration/

Skill: Tracing upstream lineage from your 3 legacy tables...
       Found 47 models in scope (out of 5,234 total in DBT project)

... (analysis runs on 47 scoped models) ...

Skill: Design document generated. Please review and reply "approved" or specify changes.

User: approved

... (generation runs) ...

Skill: Migration complete!
       - NEW tables: cnf_customers, dim_customer, fact_orders, sv_pex_analytics
       - Legacy tables (ANALYTICS_DB.*) can now be deprecated
       
       Would you like migration scripts to populate the new tables?

User: yes

Skill: Migration scripts generated at:
       /Users/me/projects/pex_migration/Data Architecture/Migration Scripts/
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill definition |
| `migration_rules.md` | Rules for model transformation |
| `dbt_best_practices.md` | DBT patterns and templates |
| `output_specification.md` | Output format specifications |
| `redundancy_patterns.md` | Patterns to detect and consolidate |
| `domains/{domain}.md` | Domain-specific rules |
