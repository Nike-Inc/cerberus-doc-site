---
layout: documentation
title: Performance Testing
---

# Executive Summary

Performance testing was executed to ensure stability of the Cerberus. 

Various load profiles were tested:

-  Burst Load - determine how well does Cerberus handle the sudden burst of requests for secrets to
come online in quick succession
-  Continuous Load Increase - tipping point for Cerberus
-  DDoS - A heavy amount of garbage traffic attempting to saturate the ELB and edge router ASG
-  Write Heavy Load - 50% reads to 50% writes

The result of this testing determined the maximum throughput Cerberus can handle is about 50 RPS using IAM auth with
95% reads to 5% writes and 95th percentile response times were with in specified SLA between 200 to 300 ms.  IAM auth
response times were 1062 ms.

Overall, this testing showed that Cerberus has a throughput limit of approximately 50 RPS with 95% reads to 5% writes, 
while the System resources was stable with CPU usage ranging from 5% - 45%.


# Objectives/Goals

The objective of the test was to determine the maximum throughput of Cerberus can handle using IAM and user auth. 
The initial request was to test at rates of 200 - 1000 RPS. However, this was adjusted to 50 RPS based on reported 
performance limits of Vault (performance was not as good with Vault auditing turned on).


# Conclusions

After analyzing our test results we concluded that the maximum traffic load that Cerberus can handle is about 50 RPS 
with steady state of 5 min (IAM auth with 95% reads to 5% writes) and response times are between 200 - 300ms. 
CPU usage is consistent across tests < 45%


# Test Scenarios

We built Gatling scripts to hit Cerberus API endpoints and performed a series of load tests.

Users ramped-up in 1 minute duration using IAM Auth login process with a steady state of 5 minutes to 30 minutes
time periods based on test requirements.

Category      | Operation Performed | %Reads | %Writes    | Ramp time     | Steady state  | Requests Per Second | Error Rate | Response Time
:-----------: | :-----------: | :-----------: | :-----------: | :-----------: | :-----------: | :-----------:
Burst Load | IamReadWrite | 95% | 5% | 1 min | 5 min  | 10 | 0% | < 200 ms
Burst Load | IamReadWrite | 95% | 5% | 1 min | 5 min  | 10 | 0% | < 200 ms
Burst Load | IamReadWrite  | 95% | 5% | 1 min | 5 min  | 20 | 0% | < 250 ms
Burst Load | IamReadWrite  | 95% | 5% | 1 min | 5 min  | 30 | 0% | < 250 ms
Burst Load | IamReadWrite  | 95% | 5% | 1 min | 5 min  | 40 | 0% | < 250 ms
Burst Load | IamReadWrite  | 95% | 5% | 1 min | 5 min  | 50 | 0% | < 250 ms
Burst Load | Viewing SDB  | 95% | 5% | 1 min | 5 min | 10 | 0% | < 200 ms
Burst Load | Viewing SDB  | 95% | 5% | 1 min | 5 min | 20 | 0% | < 200 ms
Burst Load | Viewing SDB  | 95% | 5% | 1 min | 5 min | 30 | 0% | < 250 ms
Burst Load | Viewing SDB  | 95% | 5% | 1 min | 5 min | 40 | 0% | < 250 ms
Burst Load | Viewing SDB  | 95% | 5% | 1 min | 5 min | 50 | 0% | < 250 ms
Continuous Load Increase | IamReadWrite  | 95% | 5% | 1 min | 120&nbsp;min | 20 | 0% | > 300 ms
Burst Load | IamReadWrite  | 90% | 10% | 1 min | 5 min | 10 | 0% | > 450 ms
Burst Load | IamReadWrite  | 90% | 10% | 1 min | 5 min | 20 | 0% | > 500 ms
Burst Load | IamReadWrite  | 90% | 10% | 1 min | 120 min | 10 | 0% | > 600 ms
Write Heavy Load | IamReadWrite  | 50% | 50% | 1 min | 5 min | 10 | 0% | < 250 ms
Write Heavy Load | IamReadWrite  | 50% | 50% | 1 min | 5 min | 20 |    | High so deleted nodes in UI
Write Heavy Load | IamReadWrite  | 50% | 50% | 1 min | 5 min | 20 | 0% | High after deleting nodes, listing secrets > 250 ms
Write Heavy Load | IamReadWrite  | 50% | 50% | 1 min | 30 min | 10 | 0% | > 650 ms
Write Heavy Load | IamReadWrite  | 50% | 50% | 1 min | 30 min | 20 | >15% | > 15 sec
DDoS | Invalid IamReadWrite | 90% | 10% | 1 min | 5 min | 10 | 0% | < 150 ms
DDoS | Invalid IamReadWrite | 90% | 10% | 1 min | 5 min | 20 | 0% | < 150 ms
DDoS | Invalid IamReadWrite | 90% | 10% | 1 min | 30 min | 10 | 0% | < 150 ms
DDoS | Invalid IamReadWrite | 90% | 10% | 1 min | 30 min | 20 | 0% | < 250 ms
