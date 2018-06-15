---
layout: documentation
title: Audit Logging
---

The audit logging feature was introduced in v3.1.0. The audit data contains information about events in Cerberus and can be queried using SQL in AWS Athena.
This feature is off by default. You can enable audit logging as part of environment creation, or enable it for existing environments. 
The CLI has commands for creating the S3 Buckets, IAM Roles and permissions and setting up Athena and auto-populating the properties needed to enable. 

## Enable audit logging at environment creation

1. Add `enable-audit-logs: true` to your environment YAML file
1. Run `cerberus -f /path/to/env-standup.yaml create-environment`

## Enable audit logging for existing environments

1. Run `cerberus --env [environment name] enable-audit-logging-for-existing-environment`

## Running and editing queries

In the AWS console:
1. Navigate to Services -> Athena
1. Select the audit database from the drop-down in the left sidebar
1. Enter and edit query in the textbox
1. Click **Run query**
1. Click **Save as** to save the query


## Example queries

### Request count by principal
```sql
SELECT principal_name,
         count(principal_name) AS request_count
FROM audit_data
WHERE year = 2018 and month = 06
GROUP BY  principal_name
ORDER BY  request_count desc
```

### Bad auth principals
```sql
SELECT principal_name,
         count(principal_name) AS count
FROM audit_data
WHERE was_success = 'false'
GROUP BY  principal_name
ORDER BY  count desc
```

### Secure data writes
```sql
SELECT principal_name, sdb_name_slug, path, count(sdb_name_slug) AS count
FROM audit_data
WHERE path like '/v1/secret/%' 
and http_method = 'POST'
and year = 2018
and month = 05
and day >= 01
GROUP BY  principal_name, sdb_name_slug, path
ORDER BY  count desc;
```

### Client version counts
```sql
SELECT client_version,
         count(client_version) AS count
FROM audit_data
WHERE path like '/v%/auth/%'
GROUP BY  client_version
ORDER BY  count desc;
```