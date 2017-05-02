---
layout: post
title: New CloudFormation Parameters
date:   2017-04-17 12:00:00 -0700
categories: news
---

CloudFormation templates have been improved for safer upgrades and to support additional parameters.

Previously the CloudFormation rolling update policy in the CLI would:

1. Take an instance out of service.
2. Add a new instance.
3. Wait for the new instance to become healthy before moving onto the next instance.  

Now the update policy will:

1. Add an instance to the AutoScaling group
2. Wait for it to become healthy
3. Remove an old instance and then move onto the next instance.

To take advantage of this new behavior when deploying new versions of CMS, Vault, Consul, or Gateway the next time:

1. Use the CLI's `update-stack` command.
2. Supply the `--overwrite-template` flag.
3. Supply values for the new parameters, e.g. `-PdesiredInstances=3 -PmaximumInstances=4 -PminimumInstances=3 -PpauseTime=PT15M -PwaitOnResourceSignals=True`.