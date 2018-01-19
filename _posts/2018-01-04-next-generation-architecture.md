---
layout: post
title: Next Generation of Cerberus Architecture Released
date:   2018-01-04 12:00:00 -0700
categories: news
---

We are pleased to announce the release of the next generation of Cerberus architecture.


# Improvement Highlights

### More Automated

- Completely automated deployment of an entire environment in about 1/2 hour with a single command.
- CloudFormation changes:
  - Completely rewritten templates.
  - Broken up into more stacks to ease management and support more deployment configurations.
  - Ported from Troposphere to YAML.
- TLS Certificate generation and rotation has been completely automated.

### Simplified

- Simplifying from 4 micro-services down to 1 micro-service, from 4 ELBs to 1 ALB.
- Removed dependency on CloudFront (AWS has made WAF functionality available for ALBs so CloudFront is no longer needed).
- Secrets encryption is now done with the AWS Encryption SDK instead of Vault (fewer dependencies).

### Improved Performance

- Improved baseline.
  - Max requests per second improved.
  - Greatly reduced latency.
- More easily scaled with additional hardware.

### Miscellaneous Improvements

- Switching from MySQL RDS to Amazon Aurora.
- Additional HTTP Security Headers added.
- REST API is backwards compatible for clients.
- Many additional tests added to the integration test suite (testing error conditions, more API contract validation).

# Upgrading from previous generation

Since this release includes so many changes it is NOT possible to upgrade in place.

Instead the basic procedure is:

1. Stand-up new environment with temporary DNS.
2. Apply backup from old environment to new environment.
3. Update DNS to point to new environment.

## Preparation

1. Set IAM and user token TTL to 5 mins (a few hours ahead of cut-over, this will minimize errors due to invalid token later).

```bash
# Using CLI version 3.3.1
cerberus -e XXX -r us-west-2 update-cms-config -P cms.user.token.ttl.override=5m -P cms.iam.token.ttl.override=5m
cerberus -e XXX -r us-west-2 rolling-reboot --proxy-port XXXX --proxy-type SOCKS --proxy-host XXXX rolling-reboot --stack-name CMS
```

2. Build new CMS AMI (from highlander branch).

3. Make new environment YAML file.
   * Use new CMS AMI ID.
   * Include original environment CNAME in 'additional-subject-name' section in the YAML (e.g. if creating dev2 environment make sure to add original dev.cerberus.example.com CNAME).
4. Create new environment using the CLI:

```bash
# Using CLI version 4.x.x
cerberus -f /path/to/yaml create-environment
```
5. Port WAF manual whitelist and blacklist to new environment.
6. Deploy rate limiting lambda.
7. Verify new environment is healthy.

## Cut Over

1. Temporarily stop writing to Cerberus.
2. Trigger backup job for old environment (using CLI version 3.3.1).
3. Retrieve a token from Cerberus with admin permissions (log into dashboard, or use token bash script).
4. Export VAULT_TOKEN variable in terminal window where running CLI.
5. Whitelist your IP so it will not be rate limited when restoring the backup.
6. Once backup job is finished, restore backup:

```bash
# Using CLI version 4.x.x
cerberus -e XXX -r us-west-2 restore-complete -s3-bucket XXX-us-east-1-backup-XXXX-XXX-XXX -s3-prefix 2017-01-XX-XX-XX-XX -s3-region us-east-1 -url https://dev2.cerberus.example.com
```

7. Switch old CNAME to point to the new CNAME in the AWS console (e.g. dev.cerberus.example.com → dev2.cerberus.example.com).
  * Keep track of the old CNAME value for rollback (or you can always retrieve it from the CloudFront console).
  * May take a while to propagate (expected: ~5 mins).
  * Expect possible spike in 401s from invalid tokens after environment switch (clients may try using tokens from old environment against new environment).
