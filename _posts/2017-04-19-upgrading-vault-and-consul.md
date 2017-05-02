---
layout: post
title: Upgrading Vault and Consul
date:   2017-04-19 12:00:00 -0700
categories: news
---

Puppet modules for Vault and Consul have been updated to new versions.

- Consul has been upgraded from 0.6.4 to 0.7.5.  
- Vault has been upgraded from 0.6.0 to 0.7.0.

Related to this change is a new `update-consul-config` command that has been added to the CLI.
When upgrading Consul, `update-consul-config` needs to be ran to apply changes needed for 0.7.5.

- Running `update-consul-config` with CLI version 1.0.0 or newer will make the config changes needed for Consul 0.7.x or newer.
- Running `update-consul-config` with CLI version 0.19.0 will apply config changes needed to downgrade to Consul 0.6.4.

In our testing, rolling back Consul by downgrading versions worked flawlessly assuming the Consul configuration
matched the Consul version.  Rolling back Vault and downgrading versions did not work.  To rollback Vault it
was necessary to restore from backup.

We recommend upgrading Consul and then Vault.

**IMPORTANT!!! Practice this upgrade in a test environment or risk wiping out your system**

Upgrade directions:

1. Bake new AMIs for both Vault and Consul.
2. Running `update-consul-config` with CLI version 1.0.0 or newer to make the config changes needed for Consul 0.7.x or newer.
3. Upgrade Consul using the  `update-stack` command with the `--overwrite-template` flag while supplying values for the new parameters, 
e.g. `-PdesiredInstances=3 -PmaximumInstances=4 -PminimumInstances=3 -PpauseTime=PT15M -PwaitOnResourceSignals=True`.
4. Upgrade Vault using the same parameters.

**WARNING!!!**

1. If you do not use `update-consul-config` you may wipe out your Consul cluster.
2. If you do not supply values for the new CloudFormation parameters (above) you may go to zero instances.

More here:

- [https://github.com/Nike-Inc/cerberus-consul-puppet-module](https://github.com/Nike-Inc/cerberus-consul-puppet-module)
- [https://github.com/Nike-Inc/cerberus-vault-puppet-module](https://github.com/Nike-Inc/cerberus-vault-puppet-module)

