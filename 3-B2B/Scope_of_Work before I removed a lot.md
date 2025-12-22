# Scope of Work: Canva B2B Data Pipeline Enhancement
## Professional Services Engagement

---

## Document Control
- **Version:** 1.1
- **Date:** December 2025
- **Project Name:** Canva B2B Pipeline H1 2026
- **Client:** Canva
- **Service Provider:** Snowflake Professional Services
- **Engagement Type:** Fixed Scope - Time & Materials
- **Primary Contact (Snowflake):** Mazen Hindi
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
**Total Estimated Effort:** 585-710 hours

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| Lead Architect / Consultant | 60-70 |
| OpenFlow Specialist | 30-40 |
| Data Engineer | 20-25 |
| **Phase Total** | **110-135 hours** |

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| OpenFlow Specialist | 60-70 |
| Data Engineer | 40-50 |
| Lead Consultant (oversight) | 15-20 |
| **Phase Total** | **115-140 hours** |

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| Data Engineer | 80-90 |
| OpenFlow Specialist | 50-60 |
| Lead Consultant | 30-35 |
| Security/DevOps Specialist | 15-20 |
| **Phase Total** | **175-205 hours** |

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| Data Engineer | 40-50 |
| OpenFlow Specialist | 30-35 |
| Lead Consultant | 20-25 |
| **Phase Total** | **90-110 hours** |

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| Lead Consultant | 15-20 |
| Data Engineer | 10-12 |
| OpenFlow Specialist | 8-10 |
| **Phase Total** | **33-42 hours** |

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

#### Effort Estimate
| Role | Hours |
|------|-------|
| Lead Consultant | 30-35 |
| Data Engineer | 20-25 |
| OpenFlow Specialist | 12-18 |
| **Phase Total** | **62-78 hours** |

---

## 3. Project Timeline

### 3.1 High-Level Timeline (18 Weeks Total: 14 Weeks Core + 4 Weeks Hypercare)

```
Week: 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18
     [Phase 1 ] [Phase 2   ] [Phase 3      ] [Ph4   ] [5][Phase 6      ]
     [Design  ] [Monitor   ] [Webhook      ] [Source] [KT][Hypercare    ]
```

### 3.2 Detailed Schedule

| Phase | Duration | Start Week | End Week | Key Milestone |
|-------|----------|------------|----------|---------------|
| Phase 1: Discovery & Design | 3 weeks | Week 1 | Week 3 | Design Approval |
| Phase 2: Monitoring Framework | 3 weeks | Week 4 | Week 6 | Monitoring Live |
| Phase 3: Webhook Pattern | 4 weeks | Week 7 | Week 10 | Pattern Complete |
| Phase 4: First Source | 3 weeks | Week 11 | Week 13 | Production Live |
| Phase 5: Knowledge Transfer | 1 week | Week 14 | Week 14 | Training Complete |
| Phase 6: Hypercare & Handover | 4 weeks | Week 15 | Week 18 | BAU Transition |

### 3.3 Critical Milestones

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
| **Lead Consultant / Architect** (Mazen Hindi) | Overall project leadership, architecture design, stakeholder management, technical reviews | 30-40% |
| **Senior Data Engineer** | Implementation lead, transformation logic, integration development, testing | 50-60% |
| **OpenFlow Specialist** | Monitoring framework, pipeline design, OpenFlow best practices, troubleshooting | 40-50% |
| **Security/DevOps Specialist** | Security review, authentication setup, deployment automation | 10-15% (Phase 3 only) |

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

| Phase | Hours (Low) | Hours (High) | Average |
|-------|-------------|--------------|---------|
| Phase 1: Discovery & Design | 110 | 135 | 123 |
| Phase 2: Monitoring Framework | 115 | 140 | 128 |
| Phase 3: Webhook Pattern | 175 | 205 | 190 |
| Phase 4: First Source Integration | 90 | 110 | 100 |
| Phase 5: Knowledge Transfer | 33 | 42 | 38 |
| Phase 6: Hypercare & Handover | 62 | 78 | 70 |
| **Total Project Hours** | **585** | **710** | **649** |

### 5.2 Effort Summary by Role

| Role | Hours (Low) | Hours (High) | Average |
|------|-------------|--------------|---------|
| Lead Consultant / Architect | 175 | 210 | 193 |
| Senior Data Engineer | 185 | 225 | 205 |
| OpenFlow Specialist | 190 | 220 | 205 |
| Security/DevOps Specialist | 15 | 20 | 18 |
| Project Management | 20 | 35 | 28 |
| **Total** | **585** | **710** | **649** |

### 5.3 Cost Breakdown (Indicative)

*Note: Actual rates to be confirmed based on Snowflake Professional Services rate card and Canva's existing agreement.*

**Assumptions for estimation purposes:**
- Lead Consultant/Architect: $250-300/hour
- Senior Data Engineer: $200-250/hour
- OpenFlow Specialist: $200-250/hour
- Security/DevOps Specialist: $200-250/hour
- Project Management: $150-200/hour

| Scenario | Total Hours | Estimated Cost Range* |
|----------|-------------|----------------------|
| **Low Estimate** | 585 hours | $117,000 - $146,250 |
| **Average Estimate** | 649 hours | $129,800 - $162,250 |
| **High Estimate** | 710 hours | $142,000 - $177,500 |

**Recommended Budget:** $130,000 - $165,000 (based on average estimate)

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

| Deliverable | Format | Audience |
|------------|--------|----------|
| Current State Architecture Documentation | Confluence/Markdown | Technical team |
| Future State Architecture Design | Confluence/Markdown with diagrams | Technical team |
| Architectural Decision Records (ADRs) | Markdown | Technical team |
| Webhook Integration Pattern Specification | Technical document | Developers |
| Monitoring Framework Design Document | Technical document | Ops & Engineering |
| Configuration Template Library | YAML/JSON with examples | Ops team |
| Operational Runbooks | Confluence/Wiki | Operations team |
| Troubleshooting Guides | Confluence/Wiki | Operations team |
| Training Materials | Slides + recordings | Operations team |

### 6.2 Technical Deliverables

| Deliverable | Description | Ownership Post-Project |
|------------|-------------|------------------------|
| Monitoring Framework | Pipeline monitoring, alerts, simple dashboards | Canva operations team |
| Webhook Receiver Infrastructure | Endpoint, auth, validation, processing | Canva operations team |
| Transformation Templates | Reusable transformation logic | Canva engineering team |
| Configuration Framework | Config-driven source onboarding | Canva operations team |
| Error Handling Patterns | DLQ, alerting | Canva operations team |
| First Source Integration | Production-ready integration (Splash/Goldcast/RainFocus) | Canva operations team |
| Test Suite | Unit, integration, end-to-end tests | Canva engineering team |

### 6.3 Knowledge Transfer Deliverables

| Deliverable | Format | Duration |
|------------|--------|----------|
| Architecture & Design Training | Workshop | Half day |
| Hands-on Implementation Training | Workshop | Half day |
| Operations & Troubleshooting Training | Workshop | Half day |
| Guided Second Source Implementation | Pair programming session | During hypercare |
| Office Hours (during hypercare) | Q&A sessions | As needed |

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

### 9.3 External Dependencies

- **Third-Party Vendors:** Webhook availability and API stability from Splash, Goldcast, RainFocus
- **Snowflake Product Team:** Support for any OpenFlow product issues or limitations
- **Canva IT/Security:** Infrastructure provisioning, security approvals, network configurations

---

## 10. Governance & Communication

### 10.1 Project Governance Structure

```
Executive Sponsor (Vanessa Barcellona)
          |
    Project Steering Committee
    (Quarterly reviews)
          |
    Project Manager
    /              \
Snowflake Team   Canva Team
(Mazen + team)   (Jeno, Dave, Narmina)
```

### 10.2 Meeting Cadence

| Meeting Type | Frequency | Duration | Attendees | Purpose |
|--------------|-----------|----------|-----------|---------|
| **Project Kickoff** | Once | 2 hours | All stakeholders | Align on scope, timeline, expectations |
| **Weekly Sync** | Weekly | 1 hour | Core team (both sides) | Progress updates, blockers, decisions |
| **Design Reviews** | As needed (3-4 total) | 2 hours | Technical team | Review and approve designs |
| **Demo Sessions** | Every 2 weeks | 30 min | Core + extended team | Show progress, gather feedback |
| **Steering Committee** | Monthly | 30 min | Executives + PM | Strategic alignment, escalations |
| **Training Sessions** | During Phase 5 | Half day (x3) | Ops team + trainers | Knowledge transfer |
| **Hypercare Check-ins** | Per schedule | 30 min | Core team | Support and issue triage |

### 10.3 Communication Plan

| Stakeholder Group | Updates | Method | Frequency |
|-------------------|---------|--------|-----------|
| **Executive Sponsors** | Strategic progress, risks, decisions | Email summary + steering meetings | Monthly |
| **Project Core Team** | Detailed progress, technical issues | Weekly sync + Slack | Weekly |
| **Extended Team** | Demos, major milestones | Email + demo sessions | Bi-weekly |
| **Operations Team** | Operational changes, training | Dedicated Slack channel | As needed |

### 10.4 Status Reporting

**Weekly Status Report includes:**
- Accomplishments this week
- Planned activities next week
- Blockers and risks (RAG status)
- Milestone progress
- Budget/hours tracking

**Monthly Executive Summary includes:**
- Progress against timeline
- Key milestones achieved
- Risks and mitigation actions
- Budget status
- Upcoming critical decisions

---

## 11. Change Management

### 11.1 Change Control Process

**Change Request Procedure:**
1. Submit change request in writing (email or project tool)
2. Project Manager reviews and assesses impact
3. Impact analysis (timeline, cost, scope, risk)
4. Present to steering committee if material impact
5. Decision within 5 business days
6. Document decision and update project plan

### 11.2 Change Classification

| Type | Definition | Approval Authority |
|------|------------|-------------------|
| **Minor** | < 5 hours, no timeline impact | Project Manager |
| **Moderate** | 5-20 hours, < 1 week delay | Core team consensus |
| **Major** | > 20 hours or > 1 week delay | Steering committee |

### 11.3 Out of Scope Request Handling

Requests falling outside defined scope will be:
1. Documented in "Future Enhancements" backlog
2. Discussed for potential Phase 2 inclusion
3. Quoted separately if urgent

---

## 12. Quality Assurance

### 12.1 Code Quality Standards
- Follow Snowflake and OpenFlow best practices
- Peer review for all code changes
- Automated testing (unit + integration tests)
- Security review for authentication and data handling

### 12.2 Documentation Quality Standards
- Technical accuracy verified by subject matter experts
- Clarity reviewed by operations team (target audience)
- Examples and screenshots included
- Version controlled and maintained in Canva's system

### 12.3 Testing Strategy

| Test Type | Scope | Responsibility | Phase |
|-----------|-------|----------------|-------|
| **Unit Testing** | Individual components | Development team | Phase 3 |
| **Integration Testing** | End-to-end data flow | Development team | Phase 3-4 |
| **UAT** | Business validation | Canva team | Phase 4 |
| **Performance Testing** | Latency, throughput | Development team | Phase 3-4 |
| **Security Testing** | Authentication, data protection | Security specialist | Phase 3 |
| **Operational Testing** | Monitoring, alerting | Operations team | Phase 5 |

---

## 13. Project Closeout

### 13.1 Closeout Criteria

The project will be considered complete when:
- [x] All deliverables accepted by Canva
- [x] First third-party source live in production
- [x] Operations team successfully launches second source (with guidance)
- [x] Training completed and assessed
- [x] All documentation delivered and reviewed
- [x] Hypercare period successfully completed
- [x] No high or critical severity issues open
- [x] Final project report submitted

### 13.2 Closeout Activities

1. **Final Demo:** Demonstrate all deliverables to stakeholders
2. **Documentation Handover:** Transfer all documentation to Canva systems
3. **Knowledge Transfer Verification:** Assess operations team readiness
4. **Lessons Learned Session:** Capture feedback for future engagements
5. **Final Report:** Summarize achievements, metrics, recommendations
6. **Transition to BAU:** Hand over to standard Snowflake support
7. **Customer Satisfaction Survey:** Gather feedback

### 13.3 Post-Project Support

After hypercare ends (Week 18):
- **Standard Support:** Issues handled through Canva's existing support agreement with Snowflake
- **Follow-up Review:** Optional 30-day post-project review meeting
- **Enhancement Requests:** Captured for potential Phase 2 engagement

---

## 14. Terms & Conditions

### 14.1 Engagement Model
- **Type:** Fixed scope, time and materials
- **Estimated Effort:** 585-710 hours
- **Duration:** 18 weeks (14 weeks core implementation + 4 weeks hypercare)
- **Billing:** Bi-weekly based on actual hours worked
- **Rate Card:** Per Snowflake Professional Services standard rates (or per existing Canva agreement)

### 14.2 Resource Commitment
- Snowflake team commitment as outlined in Section 4.1
- Canva team availability as outlined in Section 4.2
- 30-day advance notice required for resource changes

### 14.3 Expenses
- Remote engagement (no travel expected)
- Any required travel must be pre-approved and billed separately
- Third-party tool/API costs are Canva's responsibility

### 14.4 Intellectual Property
- Implementation code and configurations: Canva owns
- Reusable patterns and frameworks: Snowflake may reuse (anonymized)
- Documentation specific to Canva: Canva owns
- General best practices documentation: Snowflake may reuse

### 14.5 Confidentiality
- All parties bound by existing Snowflake-Canva agreement
- Canva data treated as confidential
- Architecture details not shared externally without approval

---

## 15. Approvals

### 15.1 Scope Approval

By signing below, both parties agree to the scope, timeline, deliverables, and terms outlined in this Statement of Work.

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Canva Technical Lead** | Jeno | | |
| **Canva Executive Sponsor** | [Name/Title] | | |
| **Snowflake PS Lead** | Mazen Hindi | | |
| **Snowflake Account Director** | Vanessa Barcellona | | |

### 15.2 Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | Mazen Hindi | Initial version |
| 1.1 | December 2025 | Mazen Hindi | Updated based on scope refinement discussions |
| | | | |

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

## Appendix B: Contact Information

### Snowflake Team
- **Mazen Hindi:** Lead Professional Services Consultant - [email]
- **Vanessa Barcellona:** Global Account Director - [email]
- **[Data Engineer Name]:** Senior Data Engineer - [email]
- **[OpenFlow Specialist Name]:** OpenFlow Specialist - [email]

### Canva Team
- **Jeno:** Technical Lead - [email]
- **Data Engineer/Architect:** [Name] - [email]
- **Dave:** OpenFlow Specialist - [email]
- **Narmina:** Operations Team Lead - [email]
- **Adrian:** [Role] - [email]

---

## Appendix C: Reference Documents

1. Initial Meeting Summary (provided)
2. Canva B2B Requirements Document (companion to this SOW)
3. Third-Party API Documentation (Splash, Goldcast, RainFocus, G2)
4. Snowflake-Canva Partnership Agreement (Sept 30, 2024)
5. OpenFlow Best Practices Guide
6. Canva B2B Express Schema Documentation

---

**End of Scope of Work Document**

*This document serves as the basis for the professional services engagement between Snowflake and Canva. Any modifications must be agreed upon in writing by both parties through the change control process outlined in Section 11.*

