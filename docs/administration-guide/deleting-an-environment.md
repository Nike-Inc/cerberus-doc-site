---
layout: documentation
title: Deleting a Cerberus Environment
---

1. Use the `delete-environment` CLI command which will delete all of the CloudFormation stacks.
1. Manually delete all KMS keys that were associated with the environment.
1. Manually delete lambdas associated with the environment.
1. Manually delete any remaining S3 buckets associated with the environment (should be none).
1. Manually delete any remaining RDS snapshots associated with the environment.
