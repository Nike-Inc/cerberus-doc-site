---
layout: documentation
title: Monitoring
---

Monitoring should be setup for all of the Cerberus services with the tools used by your organization.

# Health Check Lambda

A <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda')" href="https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda">Health Check Lambda / API Gateway endpoint</a> that provides an end-to-end test of the 
general health of the production Cerberus environment. It checks that a lambda can authenticate with Cerberus which 
will exercise the Cerberus Management Service (CMS) and its RDS DB.  The lambda can be invoked via the AWS API Gateway 
and monitored by another tool.

# HTTP Metrics

Monitoring HTTP response codes CMS gives a good indication of health and activity within the system, 
e.g. aggregating data from /var/log/cms/cms.log and displaying on a dashboard or metric based alerting.

# References

* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda')" href="https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda">Health Check Lambda Github</a>
* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/lambda/')" href="https://aws.amazon.com/lambda/">AWS Lambda</a>
* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/api-gateway/')" href="https://aws.amazon.com/api-gateway/">AWS API Gateway</a>
* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/rds/')" href="https://aws.amazon.com/rds/">Amazon Relational Database Service (RDS)</a>