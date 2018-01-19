---
layout: documentation
title: Upgrading an Environment
---

# General Notes

The Cerberus project uses <a target="_blank" onclick="trackOutboundLink('http://semver.org/')" href="http://semver.org/">semantic versioning</a>.  Changes to the major version number are used to
indicate backwards incompatibility and/or that extra care or steps are needed.  Whenever a major version number changes
please check this website and/or release notes for additional instructions.

## Cerberus Lifecycle CLI

The CLI includes a wrapper script that automatically checks for the latest version and offers to auto-update itself.

Generally it is best to run the latest version of the CLI but sometimes the latest version may not be compatible with
older Cerberus components (e.g. when the CLI has a new major version number).

The CLI includes commands to help with upgrading an environment.  Use the `update-stack` command with the 
`--overwrite-template` flag to update CloudFormation templates.  There is also commands for updating the configuration
of individual components.

The CLI can be invoked by other tools (e.g. Jenkins, Spinnaker) to create continuous delivery pipelines with automatic
validation using the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-integration-tests')" href="https://github.com/Nike-Inc/cerberus-integration-tests">integration tests</a>.

## Upgrading Cerberus AMIs

Clone or download the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-util-scripts')" href="https://github.com/Nike-Inc/cerberus-util-scripts">Cerberus Utility Script</a> project and follow
the README to create the AMI for Cerberus Management Service (CMS).

Generally new AMIs can be deployed using the CLI and the `update-stack` command.

## Upgrading CMS and the RDS Schema

CMS applies RDS schema updates automatically using <a target="_blank" onclick="trackOutboundLink('https://flywaydb.org/')" href="https://flywaydb.org/">Flyway</a>.  This makes upgrading version quite 
easy but downgrading may require a restore from backup or other manual intervention.

# Upgrading Specific Versions

* [Upgrading to CMS v3.x.x](../../news/2017/01/04/next-generation-architecture.html) Jan 4, 2018
* [Upgrading to Raft Protocol Version 3](../../news/2017/07/11/upgrading-to-raft-3.html) July 11, 2017
  * Raft 3 is needed to take advantage of the new [Autopilot](https://www.consul.io/docs/guides/autopilot.html) features in Consul
* [Upgrading Consul to version 0.8.3](../../news/2017/05/16/consul-0.8.3.html) May 16, 2017
  * Another major version upgrade for Consul
* [New Consul Permissions](../../news/2017/05/04/new-consul-permissions.html) May 4, 2017
  * The base stack needs to be updated before applying the latest Consul AMI
* [Upgrading Vault and Consul](../../news/2017/04/19/upgrading-vault-and-consul.html) April 19, 2017
  * Major version upgrades for both Vault and Consul
* [New CloudFormation Parameters](../../news/2017/04/17/new-cloudformation-parameters.html) April 17, 2017
  * Applying the new CloudFormation templates and initializing the new required paramters
* [Upgrading Gateway Config](../../news/2017/03/17/upgrading-gateway-config.html) March 17, 2017
  * Deploying changes to NGINX configuration for environments created with CLI version older than v0.15.2
