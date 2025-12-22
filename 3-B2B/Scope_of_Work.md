# Scope of Work: Canva B2B Data Pipeline Enhancement
## Professional Services Engagement

---

## Document Control
- **Version:** 1.2
- **Date:** December 2025
- **Project Name:** Canva B2B Pipeline H1 2026
- **Client:** Canva
- **Service Provider:** Snowflake Professional Services
- **Engagement Type:** Fixed Scope - Time & Materials
- **Primary Contact (Snowflake):** Snowflake Professional Services
- **Primary Contact (Canva):** Jeno

---

## Executive Summary

Snowflake Professional Services will partner with Canva to design, implement, and operationalize a scalable webhook integration pattern for ingesting B2B lead data from third-party sources (Splash, Goldcast, RainFocus, G2) into their Snowflake-based data pipeline using OpenFlow. This engagement includes establishing monitoring and alerting frameworks, implementing the first integration, and enabling Canva's operations team to independently launch subsequent integrations.

**Key Deliverables:**
- Webhook integration pattern design and documentation
- Monitoring and alerting framework on OpenFlow
- First third-party source integration (reference implementation)
- Knowledge transfer and operational runbooks
- Hypercare support for production stabilization

**Timeline:** 18 weeks (14 weeks core implementation + 4 weeks hypercare)
**Total Estimated Effort:** 715 hours

---

## 1. Project Scope

### 1.1 In Scope

#### 1.1.1 Architecture & Design
- Review and document current B2B data pipeline architecture
- Design scalable webhook integration pattern for third-party sources
- Evaluate transformation placement options (OpenFlow vs. Snowflake native)
- Create architectural decision records (ADRs) with pros/cons analysis
- Design monitoring and alerting framework for data pipelines
- Define configuration-driven approach for new source onboarding
- Recommend architectural and pattern changes based on any limitations identified in current state components (OpenFlow, DynamoDB, etc.)

#### 1.1.2 Implementation
- Build monitoring and alerting capabilities for data pipelines
- Verify and enhance webhook receiver infrastructure
- Create transformation templates for field mapping and validation
- Build error handling and dead-letter queue patterns
- Configure simple monitoring dashboards and alerts for operations team
- Integrate first third-party source (Splash, Goldcast, or RainFocus - TBD)

#### 1.1.3 Documentation & Knowledge Transfer
- Architecture documentation (current and future state)
- Pattern implementation guide for webhook integrations
- Configuration templates and examples
- Operations runbooks for common scenarios
- Troubleshooting guides
- Training sessions for Canva operations team

#### 1.1.4 Handover & Hypercare
- Structured handover to Canva operations team
- 4-week hypercare support post-implementation
- Guided implementation of second source with operations team
- Performance tuning and optimization
- Issue resolution and escalation support

### 1.2 Out of Scope

The following items are explicitly excluded from this engagement:

- AI/ML integration and Snowflake Intelligence implementation
- Clay enrichment data integration
- Optimization of Salesforce/Braze outbound pipelines
- Changes to DynamoDB (PPS/BPS) architecture
- Migration of existing 50-60 internal forms (already completed)
- Implementation of sources beyond the first reference implementation (Canva team will implement 2-4 additional sources)
- Fivetran replacement for non-lead data pipelines
- IPO readiness workstreams unrelated to B2B data pipeline

### 1.3 Assumptions

1. Canva provides timely access to required environments and documentation
2. Third-party source (for first implementation) provides webhook or API access
3. OpenFlow production environment is stable and accessible
4. Canva operations team is available for training sessions
5. API credentials and access to third-party platforms will be provided by Canva
6. Current DynamoDB to Snowflake CDC pipeline is stable
7. Canva technical team is available for technical reviews through implementation
8. Webhook infrastructure (receiver endpoints, authentication/authorization, rate limiting, request validation, async processing queue) is already set up by Canva or will be provided as a foundation
9. Architectural and pattern changes will be made based on any limitations identified in current state architecture components (including OpenFlow, DynamoDB, etc.) during the design and implementation phases

---

## 2. Project Phases & Deliverables

### Phase 1: Discovery & Architecture Design (Weeks 1-3)

#### Objectives
- Understand current architecture in detail
- Design scalable integration patterns
- Define monitoring framework requirements
- Align on technical approach with Canva team

#### Activities

**Week 1: Current State Assessment**
- Conduct architecture deep-dive sessions with Canva team
- Review existing OpenFlow pipelines and configurations
- Document current data flow (external sources → OpenFlow → DynamoDB → Snowflake → OpenFlow → Salesforce)
- Review B2B Express schema and data models
- Assess current monitoring capabilities and gaps
- Review third-party source documentation (Splash, Goldcast, RainFocus, G2)

**Week 2: Pattern Design**
- Design webhook receiver architecture
- Define transformation approach and placement
- Design error handling
- Design idempotency and duplicate detection strategy
- Create configuration-driven framework design
- Design monitoring and alerting framework
- Evaluate and document architectural options with pros/cons
- Suggest changes to current state ingestion mechanism and/or technologies based on assessment

**Week 3: Design Review & Alignment**
- Present design options to Canva stakeholders
- Conduct technical design review sessions
- Finalize architecture decisions (ADRs)
- Define success metrics and KPIs
- Prioritize first third-party source for implementation
- Create detailed implementation plan

#### Deliverables
- ✅ Current State Architecture Documentation
- ✅ Future State Architecture Design
- ✅ Architectural Decision Records (ADRs)
- ✅ Webhook Integration Pattern Specification
- ✅ Monitoring Framework Design Document
- ✅ Implementation Plan and Timeline

---

### Phase 2: Monitoring Framework Implementation (Weeks 4-6)

#### Objectives
- Build monitoring and alerting capabilities for the data pipeline
- Create simple operational dashboards
- Enable operations team to monitor pipeline health
- Unblock production release of existing 50-60 forms

#### Activities

**Week 4: Monitoring Setup**
- Configure monitoring components for the data pipeline
- Set up logging and metrics collection
- Implement pipeline health checks
- Create data quality validation checks
- Define alerting rules and thresholds

**Week 5: Dashboard & Alerting**
- Build simple operational dashboards using Snowflake Dashboards or Streamlit (pipeline status, throughput, errors)
- Configure alert notifications (email, Slack, PagerDuty, etc.) - optional, pending system-related blockers
- Implement performance metrics tracking (latency, SLO)
- Create simple data quality dashboards (row counts, null rates, schema validation)

**Week 6: Testing & Documentation**
- Test monitoring across existing forms
- Validate alert triggers and notifications
- Create monitoring operations guide
- Train operations team on dashboard usage
- Document monitoring configuration for new sources

#### Deliverables
- ✅ Monitoring and Alerting Capabilities
- ✅ Simple Operational Dashboards (Snowflake Dashboards or Streamlit)
- ✅ Alert Configuration (if no system blockers)
- ✅ Monitoring Operations Guide
- ✅ Training Session for Operations Team

---

### Phase 3: Webhook Pattern Implementation (Weeks 7-10)

#### Objectives
- Build reusable webhook integration pattern
- Create configuration templates
- Implement transformation and validation logic
- Establish error handling patterns

#### Activities

**Week 7: Infrastructure Verification**
- Verify webhook receiver endpoints setup
- Verify authentication/authorization implementation
- Verify rate limiting and throttling configuration
- Verify request validation setup
- Verify async processing queue implementation

**Week 8: Transformation & Processing**
- Build transformation templates (field mapping, value constraints)
- Implement configuration-driven transformation engine
- Build error handling
- Implement dead-letter queue for failed records

**Week 9: Integration & End-to-End Testing**
- Integrate webhook receiver with OpenFlow
- Implement connection to DynamoDB (PPS/BPS) or other pattern changes agreed upon in design phase
- Test end-to-end data flow
- Validate transformation logic
- Test error scenarios

**Week 10: Optimization & Documentation**
- Performance testing and tuning
- Implement post-testing changes based on outcomes from Week 9 testing
- Create configuration templates
- Prepare for first source integration

#### Deliverables
- ✅ Webhook Receiver Infrastructure
- ✅ Transformation Templates and Engine
- ✅ Error Handling Logic
- ✅ Configuration Framework
- ✅ Configuration Template Library
- ✅ Unit and Integration Tests

---

### Phase 4: First Source Integration (Weeks 11-13)

#### Objectives
- Implement first third-party source as reference
- Validate pattern in production
- Ensure data flows meet SLA requirements
- Demonstrate operational readiness

#### Activities

**Week 11: Source Configuration**
- Review third-party source API/webhook documentation
- Configure source-specific transformations
- Set up authentication and credentials
- Create source configurations
- Configure monitoring for new source

**Week 12: Implementation & Testing**
- Implement source-specific webhook handler
- Configure field mappings and validations
- Test data ingestion from third-party source
- Validate data quality in DynamoDB and Snowflake
- Test error handling and recovery scenarios
- Conduct UAT with Canva team

**Week 13: Production Deployment**
- Deploy to production environment
- Monitor initial data flow
- Validate SLA compliance (15-minute target)
- Performance tuning as needed
- Prepare deployment runbook and obtain Canva approval

#### Deliverables
- ✅ First Third-Party Source Integration (Production-Ready)
- ✅ Source-Specific Configuration
- ✅ Validation Test Results
- ✅ Production Deployment Documentation
- ✅ Deployment Runbook (approved by Canva)

---

### Phase 5: Knowledge Transfer & Handover (Week 14)

#### Objectives
- Transfer knowledge to Canva operations team
- Create comprehensive operational documentation
- Prepare team for independent operation

#### Activities

**Week 14: Training & Documentation**
- Conduct architecture and design training session
- Conduct hands-on implementation training
- Conduct operations and troubleshooting training
- Create operational runbooks
- Create troubleshooting guides

#### Deliverables
- ✅ Training Sessions (Architecture, Implementation, Operations)
- ✅ Operational Runbooks
- ✅ Troubleshooting Guides

---

### Phase 6: Hypercare Support (Weeks 15-18)

#### Objectives
- Provide elevated support during stabilization period
- Monitor system performance and stability
- Address issues and optimize as needed
- Enable self-service source onboarding
- Ensure smooth transition to BAU operations

#### Activities

**Weeks 15-18: Post-Production Support**
- Daily monitoring of pipeline health (Week 15)
- Regular check-ins with operations team (3x per week → 2x → 1x)
- Issue triage and resolution support
- Performance optimization as needed
- Documentation updates based on operational feedback
- Guide operations team through second source configuration
- Review and provide feedback on their implementation
- Conduct handover readiness assessment
- Formalize handover checklist and sign-off
- Final knowledge transfer session

**Support Model:**
- **Week 15:** Daily sync, active monitoring, immediate response
- **Week 16:** 3x per week sync, proactive monitoring
- **Week 17:** 2x per week sync, reactive support
- **Week 18:** 1x per week sync, escalation support only

#### Deliverables
- ✅ Daily/Weekly Status Reports
- ✅ Issue Resolution Log
- ✅ Performance Optimization Report
- ✅ Updated Documentation (based on operational learnings)
- ✅ Second Source Configuration (Guided)
- ✅ Handover Checklist and Sign-off
- ✅ Hypercare Closeout Report
- ✅ Transition to BAU Support

---

## 3. Project Timeline

### 3.1 Detailed Schedule

| Phase | Duration | Start Week | End Week | Key Milestone |
|-------|----------|------------|----------|---------------|
| Phase 1: Discovery & Design | 3 weeks | Week 1 | Week 3 | Design Approval |
| Phase 2: Monitoring Framework | 3 weeks | Week 4 | Week 6 | Monitoring Live |
| Phase 3: Webhook Pattern | 4 weeks | Week 7 | Week 10 | Pattern Complete |
| Phase 4: First Source | 3 weeks | Week 11 | Week 13 | Production Live |
| Phase 5: Knowledge Transfer | 1 week | Week 14 | Week 14 | Training Complete |
| Phase 6: Hypercare & Handover | 4 weeks | Week 15 | Week 18 | BAU Transition |

### 3.2 Critical Milestones

| Milestone | Target Week | Importance |
|-----------|-------------|------------|
| Project Kickoff | Week 1 | Project start |
| Design Approval | Week 3 | Go/No-Go decision point |
| Monitoring Live | Week 6 | Unblock forms release |
| Pattern Complete | Week 10 | Core deliverable |
| First Source Live | Week 13 | Production deployment |
| Training Complete | Week 14 | Team enablement |
| Handover Complete | Week 18 | BAU transition |

---

## 4. Resource Plan

### 4.1 Snowflake Professional Services Team

| Role | Responsibility | Commitment |
|------|---------------|------------|
| **Lead Consultant / Architect** | Overall project leadership, architecture design, stakeholder management, technical reviews | 30-40% |
| **Solution Architect** | Implementation lead, transformation logic, integration development, testing | 50-60% |
| **OpenFlow Specialist** | Monitoring framework, pipeline design, OpenFlow best practices, troubleshooting | 10-15% |

### 4.2 Canva Team Requirements

| Role | Time Commitment | Phases |
|------|----------------|--------|
| **Jeno** (Technical Lead) | 4-6 hours/week | Weeks 1-13 (before leave) |
| **Data Engineer/Architect** | 4-6 hours/week | All phases |
| **Dave** (OpenFlow Specialist) | 2-4 hours/week | Phases 2-6 |
| **Narmina & Ops Team** | 8-10 hours/week | Phases 5-6 (training & handover) |
| **Adrian** | 2-3 hours/week | As needed |

---

## 5. Cost Estimate

### 5.1 Effort Summary by Phase

| Phase | Hours |
|-------|-------|
| Phase 1: Discovery & Design | 132 |
| Phase 2: Monitoring Framework | 162 |
| Phase 3: Webhook Pattern | 176 |
| Phase 4: First Source Integration | 120 |
| Phase 5: Knowledge Transfer | 50 |
| Phase 6: Hypercare & Handover | 75 |
| **Total Project Hours** | **715** |

### 5.2 Effort Summary by Role

| Role | Hours |
|------|-------|
| Lead Consultant / Architect | 320 |
| Solution Architect | 355 |
| OpenFlow Specialist | 40 |
| **Total** | **715** |

### 5.3 Cost Breakdown (Indicative)

*Note: Actual rates to be confirmed based on Snowflake Professional Services rate card and Canva's existing agreement.*

**Assumptions for estimation purposes:**
- Lead Consultant/Architect: $250-300/hour
- Solution Architect: $200-250/hour
- OpenFlow Specialist: $200-250/hour

| Total Hours | Estimated Cost Range* |
|-------------|----------------------|
| **715 hours** | $143,000 - $178,750 |

**Recommended Budget:** $145,000 - $180,000

*\*Cost ranges are indicative. Final pricing will be based on Snowflake Professional Services standard rates and Canva's existing commercial agreement.*

### 5.4 Cost Assumptions & Exclusions

**Included in Estimate:**
- All activities outlined in Phases 1-6
- First third-party source integration
- Training and documentation
- 4-week hypercare support
- Standard project management overhead

**Not Included in Estimate:**
- Implementation of 2nd-5th third-party sources (Canva team will implement using pattern)
- Costs for third-party API usage or licenses
- Snowflake compute/storage costs
- Infrastructure costs for webhook hosting

---

## 6. Deliverables Summary

### 6.1 Documentation Deliverables

| Deliverable | Audience |
|------------|----------|
| Current State Architecture Documentation | Technical team |
| Future State Architecture Design | Technical team |
| Architectural Decision Records (ADRs) | Technical team |
| Webhook Integration Pattern Specification | Developers |
| Monitoring Framework Design Document | Ops & Engineering |
| Configuration Template Library | Ops team |
| Operational Runbooks | Operations team |
| Troubleshooting Guides | Operations team |
| Training Materials | Operations team |

### 6.2 Technical Deliverables

| Deliverable | Description |
|------------|-------------|
| Monitoring Framework | Pipeline monitoring, alerts, simple dashboards |
| Webhook Receiver Infrastructure | Endpoint, auth, validation, processing |
| Transformation Templates | Reusable transformation logic |
| Configuration Framework | Config-driven source onboarding |
| Error Handling Patterns | DLQ, alerting |
| First Source Integration | Production-ready integration (Splash/Goldcast/RainFocus) |
| Test Suite | Unit, integration, end-to-end tests |

### 6.3 Knowledge Transfer Deliverables

| Deliverable | Duration |
|------------|----------|
| Architecture & Design Training | Half day |
| Hands-on Implementation Training | Half day |
| Operations & Troubleshooting Training | Half day |
| Guided Second Source Implementation | During hypercare |
| Office Hours (during hypercare) | As needed |

---

## 7. Success Criteria & KPIs

### 7.1 Technical Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| **Data Latency** | < 15 minutes (SLA), < 5 minutes (SLO) | End-to-end from webhook to Snowflake |
| **Pipeline Availability** | > 99.5% | Uptime monitoring |
| **Data Quality** | > 99% records passing validation | Quality checks |
| **Error Rate** | < 1% failed records | Error monitoring |
| **Monitoring Coverage** | 100% of pipelines monitored | Dashboard verification |
| **Alert Response Time** | < 15 minutes for critical alerts | Operations team SLA |

### 7.2 Operational Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| **Self-Service Onboarding** | Ops team can add new source in < 5 days | Time tracking |
| **Documentation Completeness** | 100% of components documented | Review checklist |
| **Training Effectiveness** | 80%+ on post-training assessment | Quiz scores |
| **Manual Intervention Reduction** | < 10% of ingestions require manual action | Ops metrics |
| **Knowledge Transfer** | Ops team successfully launches 2nd source | Handover validation |

### 7.3 Business Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| **Timeline Adherence** | First source live by end of March | Milestone tracking |
| **Scalability** | Pattern supports 5+ sources with no changes | Architectural review |
| **Cost Efficiency** | Reduced external consulting needs | Budget tracking |
| **Team Enablement** | Canva team operates independently post-hypercare | Support tickets |

---

## 8. Risks & Mitigation Strategies

### 8.1 Schedule Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Jeno unavailable before April** | Medium | High | Prioritize critical reviews in Weeks 1-12; document decisions thoroughly |
| **Third-party API delays** | Medium | Medium | Engage third-party vendors early; have backup source option |
| **Scope creep** | Medium | Medium | Strict change control; separate "nice-to-have" for Phase 2 |
| **Holiday/vacation scheduling** | Low | Low | Identify key dates early; plan around holidays |

### 8.2 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **OpenFlow or current architecture limitations** | Medium | High | Architectural patterns will be adjusted based on identified limitations; alternative approaches designed in Phase 1 |
| **Performance issues at scale** | Medium | High | Early load testing; architecture review by Snowflake experts |
| **Integration complexity higher than expected** | Medium | Medium | Buffer hours in estimates; early POC in Phase 3 |
| **Security/compliance requirements** | Low | Medium | Early security review in Phase 1; involve security team |
| **Data quality issues** | Medium | High | Comprehensive validation; staging environment testing |

### 8.3 Organizational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Operations team bandwidth constraints** | Medium | Medium | Focused training; flexible scheduling; recorded sessions |
| **Stakeholder alignment issues** | Low | High | Regular status updates; early design reviews |
| **Knowledge retention after Jeno's leave** | Medium | High | Comprehensive documentation; cross-train multiple team members |
| **Competing priorities** | Medium | Medium | Executive sponsorship; clear communication |

---

## 9. Assumptions & Dependencies

### 9.1 Key Assumptions

1. **Environment Access:** Snowflake team will receive full access to OpenFlow production and development environments by project kickoff
2. **Data Access:** Access to B2B Express schemas, DynamoDB structure, and sample data will be provided
3. **Third-Party Documentation:** API documentation for Splash, Goldcast, RainFocus is available and complete
4. **Credentials:** API keys and authentication credentials for third-party sources will be provided by Canva
5. **Team Availability:** Canva technical team available for weekly design reviews and bi-weekly status meetings
6. **OpenFlow Stability:** OpenFlow platform is production-ready and stable for new implementations
7. **Infrastructure:** Webhook hosting infrastructure is available or can be provisioned quickly
8. **Approval Process:** Technical decisions can be approved within 3-5 business days

### 9.2 Critical Dependencies

| Dependency | Owner | Required By | Risk Level |
|------------|-------|-------------|------------|
| OpenFlow environment access | Canva | Week 1 | High |
| Third-party API documentation | Canva | Week 2 | High |
| Schema and data model documentation | Canva | Week 1 | Medium |
| API credentials for first source | Canva | Week 11 | High |
| Operations team availability for training | Canva | Phase 5 | Medium |
| Design approval from stakeholders | Canva | Week 3 | High |
| Webhook infrastructure foundation | Canva/IT | Week 7 | Medium |

---

## Appendix A: Acronyms & Glossary

| Term | Definition |
|------|------------|
| **ADR** | Architectural Decision Record |
| **API** | Application Programming Interface |
| **BAU** | Business As Usual |
| **B2B Express** | Canva's Snowflake database for B2B data (3 schemas: source, model, target) |
| **CDC** | Change Data Capture (tool for DynamoDB → Snowflake replication) |
| **DLQ** | Dead Letter Queue (for failed messages) |
| **KPI** | Key Performance Indicator |
| **NiFi** | Apache NiFi (basis for OpenFlow) |
| **OpenFlow** | Snowflake's data integration tool |
| **PPS/BPS** | Backend service on DynamoDB for lead processing |
| **SLA** | Service Level Agreement (15 minutes for Canva) |
| **SLO** | Service Level Objective (2-5 minutes target for Canva) |
| **UAT** | User Acceptance Testing |

---

**End of Scope of Work Document**

