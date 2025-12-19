# Requirements Document: Canva B2B Data Pipeline Enhancement
## Project Overview
Canva requires professional services support to design, implement, and optimize their B2B data pipeline architecture for ingesting and processing lead data from multiple third-party sources using Snowflake OpenFlow.

## Document Control
- **Version:** 1.0
- **Date:** December 19, 2025
- **Project Name:** Canva B2B Pipeline H1 2026
- **Client:** Canva
- **Service Provider:** Snowflake Professional Services

---

## 1. Business Context

### 1.1 Background
- Canva is one of Snowflake's top 10 global customers (as of Sept 30, 2024 agreement)
- Historically lacked dedicated B2B infrastructure
- Previously handled leads directly from frontend services to Salesforce, facing API limitations and data mapping challenges
- Building new solution on Snowflake to process and map leads more efficiently
- Four key strategic priorities: B2B go-to-market collaboration, accelerating AI, IPO readiness, and data platform optimization

### 1.2 Current State
- Data flows from various sources (marketing forms, LinkedIn, third parties, webinar platforms) to Salesforce
- Backend service (PPS/BPS) built on DynamoDB processes leads before Snowflake ingestion
- CDC (Change Data Capture) protocol via Snowpipe ingests data from DynamoDB to Snowflake B2B Express layer
- Data lands in Snowflake within 1 minute from DynamoDB
- OpenFlow is being implemented for faster processing and third-party integration
- 50-60 internal forms have been migrated but not fully released to production
- Currently using Fivetran for some ingestion (1-hour latency) - needs replacement for real-time requirements
- Previously used Census for pushing data to Salesforce; transitioning to OpenFlow due to need for logical reasoning capabilities

### 1.3 Key Challenges
1. **Performance:** Current transformation and processing is slow
2. **Scalability:** Manual intervention required; not sustainable for growing data sources
3. **Monitoring:** Lack of comprehensive monitoring and alerting framework on OpenFlow
4. **Latency:** Need to meet 15-minute SLA (current SLO is 2-5 minutes)
5. **Integration Complexity:** Building connections to new sources requires significant time and effort
6. **Expertise Gap:** Relying on external NiFi experts from US is not scalable
7. **Transformation Location:** Need to optimize where transformations occur in the pipeline

---

## 2. Business Requirements

### 2.1 Strategic Goals
1. **Autonomy:** Create self-maintaining pipelines requiring minimal manual intervention
2. **Scalability:** Support growing number of data sources and lead volume
3. **Speed:** Reduce lead processing time to meet business SLA
4. **Durability:** Build robust pipelines with proper error handling and monitoring
5. **Democratization:** Enable operations team to manage integrations independently after initial implementation
6. **AI-Readiness:** Ensure data architecture supports future AI/ML capabilities

### 2.2 Operational Requirements
1. **Lead Processing SLA:** 15 minutes maximum from source to Salesforce
2. **Current Performance Target:** Maintain 2-5 minute SLO
3. **Automated Ingestion:** New forms should be automatically ingested with minimal configuration
4. **Configuration-Driven:** Use templates and configuration files rather than custom code for each source
5. **Knowledge Transfer:** Canva operations team (Narmina and team) must be able to launch new sources independently

---

## 3. Technical Requirements

### 3.1 Data Architecture

#### 3.1.1 Current Architecture Components
- **External Sources:** Third-party platforms (Splash, Goldcast, RainFocus, G2, LinkedIn)
- **Internal Sources:** LeadGen (internal Canva forms - 50-60 forms)
- **Ingestion Layer:** OpenFlow
- **Backend Service:** PPS/BPS (DynamoDB)
- **Data Warehouse:** Snowflake B2B Express
  - Single database with three schema layers: source, model, target
  - Native tables (no hybrid or Iceberg)
- **Destination Systems:** Salesforce, Braze
- **Enrichment:** Clay (future) for enrichment data insertion

#### 3.1.2 Data Flow Pattern
```
External/Internal Sources 
  → OpenFlow (transformation & ingestion)
  → PPS/BPS (DynamoDB - mapping to contract rules)
  → Snowflake B2B Express (via CDC/Snowpipe - within 1 minute)
  → OpenFlow (push to Salesforce/Braze)
  → Salesforce/Braze
```

### 3.2 Integration Requirements

#### 3.2.1 Priority External Sources (H1 2026)
1. **Splash** - Webinar/event platform
2. **Goldcast** - Webinar platform
3. **RainFocus** - Event management platform
4. **G2** - Software marketplace (potential)
5. **Additional sources** - TBD based on business needs

#### 3.2.2 Integration Patterns Needed
- **Webhook Support:** Real-time webhook receivers for third-party sources
- **API Polling:** For sources without webhook capabilities
- **Standardized Transformation:** Mapping fields and enforcing value constraints
- **Error Handling:** Retry logic, dead-letter queues, alerting
- **Data Validation:** Contract rule enforcement before loading

### 3.3 Transformation Requirements

#### 3.3.1 Current Transformation Needs
- **Field Mapping:** Map source fields to target schema
- **Value Constraints:** Enforce business rules on field values
- **Qualification/Filtering:** Determine which leads to process
- **Enrichment Integration:** Support for Clay enrichment data (future)

#### 3.3.2 Transformation Location Considerations
- Currently happening in OpenFlow (before DynamoDB)
- Need to evaluate optimal location for scalability
- Options to consider:
  - Keep in OpenFlow
  - Push to later in pipeline (within Snowflake)
  - Introduce scalable transformation layer between external sources and DynamoDB

### 3.4 Monitoring & Observability Requirements

#### 3.4.1 Must-Have Monitoring Capabilities
- **Pipeline Health:** Status of each ingestion pipeline
- **Data Quality:** Row counts, null checks, schema validation
- **Performance Metrics:** Processing time, throughput, latency
- **Error Tracking:** Failed records, transformation errors, API failures
- **Alerting:** Real-time notifications for critical issues

#### 3.4.2 Monitoring Framework Scope
- Build monitoring and alerting on top of OpenFlow
- Dashboard for operations team visibility
- Integration with existing Canva monitoring systems (if applicable)
- Runbook documentation for common issues

### 3.5 OpenFlow-Specific Requirements
- **Productionization:** Complete production deployment within 1 week (already in progress)
- **Form Migration:** Release remaining internal forms after monitoring implementation
- **Webhook Functionality:** Leverage recently available webhook capabilities
- **Best Practices:** Implement NiFi/OpenFlow best practices for pipeline design

---

## 4. Functional Requirements

### 4.1 Webhook Integration Pattern
1. **Design Requirements:**
   - Secure endpoint creation for third-party webhooks
   - Authentication/authorization mechanism
   - Request validation and payload parsing
   - Idempotency handling for duplicate events
   - Rate limiting and throttling

2. **Processing Requirements:**
   - Asynchronous processing for high throughput
   - Configurable transformation rules
   - Support for both JSON and form-encoded payloads
   - Schema validation against expected contract

3. **Delivery Requirements:**
   - Guaranteed delivery to DynamoDB
   - Transaction support for data consistency
   - Rollback mechanisms for failures

### 4.2 Configuration Management
1. **Source Configuration:**
   - Define source metadata (name, type, endpoint)
   - Specify transformation rules
   - Set monitoring thresholds and alerts
   - Configure data quality checks

2. **Template Library:**
   - Reusable templates for common source types
   - Standard transformation patterns
   - Pre-built monitoring configurations
   - Documentation and examples

### 4.3 Operations Requirements
1. **Self-Service Capabilities:**
   - Operations team can add new sources using templates
   - Configure monitoring without code changes
   - View pipeline status and metrics
   - Troubleshoot issues using runbooks

2. **Documentation:**
   - Architecture decision records
   - Pattern implementation guides
   - Operations runbooks
   - Troubleshooting guides

---

## 5. Non-Functional Requirements

### 5.1 Performance
- **Latency:** Meet 15-minute SLA, target 2-5 minute SLO
- **Throughput:** Support current and projected lead volume (specific numbers TBD)
- **Scalability:** Handle 5+ external sources in H1, with room for growth

### 5.2 Reliability
- **Availability:** High availability for webhook endpoints
- **Data Integrity:** No data loss during ingestion and transformation
- **Error Recovery:** Automatic retry with exponential backoff

### 5.3 Maintainability
- **Code Quality:** Follow Snowflake and OpenFlow best practices
- **Documentation:** Comprehensive technical and operational documentation
- **Testability:** Unit and integration tests for critical components

### 5.4 Security
- **Authentication:** Secure webhook endpoints with API keys or OAuth
- **Data Protection:** Encrypt data in transit and at rest
- **Compliance:** Adhere to Canva's data governance policies

---

## 6. Constraints & Assumptions

### 6.1 Constraints
1. **Timeline:** First pattern implementation must be completed before Jeno's parental leave in April 2025
2. **Resources:** Canva operations team (Narmina and team) will handle ongoing operations
3. **Technology Stack:** Must use Snowflake OpenFlow as primary integration tool
4. **Data Flow:** Leads must flow through PPS/BPS (DynamoDB) before Snowflake (current architecture constraint, but open to optimization discussion)

### 6.2 Assumptions
1. OpenFlow webhook functionality is stable and production-ready
2. Third-party sources can provide webhook or API access
3. Canva operations team has basic NiFi/OpenFlow knowledge
4. Snowflake Professional Services team has access to third-party source documentation
5. Current DynamoDB → Snowflake CDC pipeline is stable and won't require changes
6. B2B Express database schema is stable

---

## 7. Success Criteria

### 7.1 Phase 1 Success (Design & First Implementation)
- ✅ Webhook pattern designed and documented
- ✅ Monitoring framework implemented on OpenFlow
- ✅ First third-party source (e.g., Splash) integrated successfully
- ✅ Data flowing end-to-end within 15-minute SLA
- ✅ Operations team trained on new pattern
- ✅ Documentation and runbooks completed

### 7.2 Overall Project Success
- ✅ 3-5 third-party sources integrated in H1 2026
- ✅ Operations team independently launching new sources
- ✅ Monitoring dashboards showing pipeline health
- ✅ Zero data loss incidents
- ✅ Reduced manual intervention by 80%+
- ✅ Architecture scalable for future growth

---

## 8. Dependencies

### 8.1 Canva Dependencies
1. Access to third-party source documentation (Splash, Goldcast, RainFocus, G2)
2. Credentials/API keys for third-party platforms
3. OpenFlow production environment access for Snowflake team
4. DynamoDB and B2B Express schema documentation
5. Availability of Jeno, Vishnu, and operations team for design reviews

### 8.2 Snowflake Dependencies
1. Professional Services team availability (Mazen and team)
2. OpenFlow subject matter experts for best practices review
3. Technical architecture review and approval process

### 8.3 Third-Party Dependencies
1. Webhook or API availability from external sources
2. API rate limits and documentation
3. Support for required authentication mechanisms

---

## 9. Risks & Mitigation

### 9.1 Technical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OpenFlow stability issues | High | Medium | Thorough testing, phased rollout, fallback plan |
| Third-party API changes | Medium | Medium | Version API contracts, monitoring for changes |
| Performance degradation at scale | High | Low | Load testing, performance benchmarking |
| Data quality issues | High | Medium | Comprehensive validation, monitoring, alerts |

### 9.2 Project Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Timeline delay due to complexity | Medium | Medium | Prioritize first source, parallel work streams |
| Knowledge transfer incomplete | High | Low | Structured training, comprehensive documentation |
| Jeno unavailable before handover | High | Low | Complete first implementation by end of March |
| Scope creep from new requirements | Medium | Medium | Clear scope definition, change control process |

---

## 10. Out of Scope (Phase 1)

The following items are explicitly out of scope for the initial implementation phase:

1. **AI/ML Integration:** While architecture should be AI-ready, actual AI implementation is deferred
2. **Clay Enrichment Integration:** Future enhancement
3. **Salesforce/Braze Push Optimization:** Focus is on ingestion; outbound optimization is separate
4. **DynamoDB Architecture Changes:** Assumed stable unless critical issues identified
5. **Migration of Existing 50-60 Forms:** Already completed, only monitoring needs to be added
6. **Additional Sources Beyond Initial 5:** Focus on establishing pattern first
7. **Fivetran Replacement for Non-Lead Data:** Scope limited to B2B lead data pipeline
8. **IPO Readiness Activities:** Strategic priority but separate workstream
9. **Snowflake Intelligence Implementation:** Deferred to later phase

---

## 11. Stakeholders

### 11.1 Canva Team
- **Jeno:** Lead engineer (on parental leave from April)
- **Vishnu:** Engineer/architect
- **Dave:** NiFi/OpenFlow specialist
- **Narmina & Operations Team:** Day-to-day pipeline operations
- **Adrian:** (Role TBD from meeting)

### 11.2 Snowflake Team
- **Mazen Hindi:** Lead Professional Services consultant
- **Vanessa Barcellona:** Global Account Director for Canva
- **Professional Services Team:** Design and implementation support

---

## 12. Acceptance Criteria

### 12.1 Deliverable Acceptance
Each deliverable will be considered complete when:
1. Code/configuration passes review and testing
2. Documentation is complete and reviewed
3. Training is delivered and confirmed
4. Handover checklist is signed off
5. Hypercare period is successfully completed

### 12.2 Project Acceptance
Overall project will be accepted when:
1. All Phase 1 deliverables are completed
2. First third-party source is live in production
3. Operations team demonstrates ability to add second source independently (with guidance)
4. All documentation and runbooks are delivered
5. No critical or high-severity issues remain open

---

## Appendix A: Glossary

- **B2B Express:** Canva's Snowflake database for B2B lead data (source, model, target schemas)
- **PPS/BPS:** Backend service built on DynamoDB for lead processing
- **CDC:** Change Data Capture protocol for replicating DynamoDB data to Snowflake
- **OpenFlow:** Snowflake's data integration tool (based on Apache NiFi)
- **LeadGen:** Internal Canva system for marketing form leads
- **SLA:** Service Level Agreement (15 minutes for lead processing)
- **SLO:** Service Level Objective (current target: 2-5 minutes)
- **Hypercare:** Post-implementation support period with heightened monitoring

---

## Document Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Canva Lead | Jeno | | |
| Snowflake PS Lead | Mazen Hindi | | |
| Account Director | Vanessa Barcellona | | |

---

**End of Requirements Document**

