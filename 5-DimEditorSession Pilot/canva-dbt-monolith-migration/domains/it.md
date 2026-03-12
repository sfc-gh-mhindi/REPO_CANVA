# IT Domain Rules

## Business Context
- **Owns**: Infrastructure, systems, operations, security, access management
- **Stakeholders**: IT ops, security team, platform engineering
- **Data Sensitivity**: High (contains system logs, access patterns, security events)

## Source Assumptions
| Assumption | Default | Override? |
|------------|---------|-----------|
| Source schema | `RAW.IT_OPS` | Yes |
| Log grain | Event level | Yes |
| System identifier | `system_id` | Yes |
| User identifier | `employee_id` | Yes |
| Timestamp precision | Millisecond | Yes |

## Naming Conventions
| Entity Type | Prefix | Example |
|-------------|--------|---------|
| Conformed | `cnf_it_` | cnf_it_system_events |
| Dimension | `dim_` | dim_system, dim_employee |
| Fact | `fact_it_` | fact_it_incidents |
| Semantic | `sv_it_` | sv_it_operations |

## Standard Dimensions
| Dimension | SCD Type | Key Attributes |
|-----------|----------|----------------|
| dim_system | Type 2 | system_id, system_name, system_type, environment, owner |
| dim_employee | Type 2 | employee_id, department, role, access_level |
| dim_service | Type 1 | service_id, service_name, service_tier, dependencies |
| dim_severity | Type 0 | severity_level, severity_name, response_sla |
| dim_date | Type 0 | Standard date dimension |

## Standard Facts
| Fact | Grain | Measures |
|------|-------|----------|
| fact_it_incidents | One row per incident | resolution_time_mins, is_resolved, escalation_count |
| fact_it_deployments | One row per deployment | deployment_duration_mins, rollback_count, is_successful |
| fact_it_access_logs | One row per access event | is_successful, is_anomalous |
| fact_it_system_metrics | One row per system per hour | cpu_pct, memory_pct, disk_pct, error_count |

## Business Logic Defaults

### Severity Levels
```sql
CASE
    WHEN impact = 'CRITICAL' AND urgency = 'HIGH' THEN 'P1'
    WHEN impact = 'HIGH' AND urgency = 'HIGH' THEN 'P2'
    WHEN impact IN ('CRITICAL', 'HIGH') OR urgency = 'HIGH' THEN 'P3'
    ELSE 'P4'
END
```

### SLA Targets
| Priority | Response | Resolution |
|----------|----------|------------|
| P1 | 15 mins | 4 hours |
| P2 | 30 mins | 8 hours |
| P3 | 2 hours | 24 hours |
| P4 | 8 hours | 72 hours |

### System Health Score
```sql
CASE
    WHEN error_rate > 0.05 OR latency_p99 > 1000 THEN 'CRITICAL'
    WHEN error_rate > 0.01 OR latency_p99 > 500 THEN 'DEGRADED'
    WHEN error_rate > 0.001 OR latency_p99 > 200 THEN 'WARNING'
    ELSE 'HEALTHY'
END
```

### Environment Classification
| Environment | Code |
|-------------|------|
| Production | PROD |
| Staging | STG |
| Development | DEV |
| Sandbox | SBX |

## Testing Requirements
| Test | Threshold | Apply To |
|------|-----------|----------|
| Unique | 100% | All surrogate keys, incident_id |
| Not null | 100% | system_id, timestamps, severity |
| Accepted values | environment | PROD, STG, DEV, SBX |
| Accepted values | severity | P1, P2, P3, P4 |
| Freshness | < 1 hour | System metrics |
| Row count | > 0 | All tables |

## Incremental Strategy
- **Default**: Append for logs, merge for dimensions
- **Lookback**: 1 day (for log corrections)
- **Unique key**: event_id or incident_id
- **Partition**: By event_date for large log tables

## Notes
- IT data is often extremely high volume (billions of log events)
- Consider aggressive partitioning and clustering
- Security-sensitive data may require masking policies
- Retain raw logs for compliance (typically 90-365 days)
- System metrics should be pre-aggregated to hourly grain for reporting
