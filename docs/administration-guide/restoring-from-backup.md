---
layout: documentation
title: Restoring from Backup
---

Restoring Cerberus data is made easy through RDS snapshots and CloudFormation parameters.

## Restore to an Existing Cerberus Environment

In the AWS Console:

1. Navigate to **Services -> RDS -> Snapshots**
1. Type the Cerberus environment name into the snapshot filter search bar (e.g. **test**)
1. Click the link for the desired snapshot
1. On the snapshot details page, copy the **DB snapshot name**
1. Navigate to **Services -> CloudFormation**
1. Type the Cerberus environment name into the CloudFormation Stack filter search bar (e.g. **test**)
1. Select the database stack (e.g. **ENV-cerberus-database**)
1. Click the **Actions** dropdown and select **Update Stack**
1. Make sure **Use current template** is selected, then click **Next**
1. On the **Specify Details** page, paste the copied DB snapshot name into the '**snapshotIdentifier**' field
1. Click **Next**
1. Click **Next** again
1. Click **Update**

## Restore to a New Cerberus Environment

Add the following to the Cerberus 'environment.yaml' before creating the environment:

```yaml
region-specific-configuration:
  us-west-2:
    primary: true
    rds:
      size: db.r3.large
      # To create a new environment from a rds backup snapshot uncomment below and supply the db cluster snapshot identifier
      db-cluster-identifier: foo-bar
```

Next, follow instructions on [Creating a Cerberus Environment](/cerberus/docs/administration-guide/creating-an-environment).

