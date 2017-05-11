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
the README to create AMIs for Consul, Vault, Gateway, and Cerberus Management Service (CMS).

Generally new AMIs can be deployed using the CLI and the `update-stack` command but sometimes extra steps are needed.

## Upgrading Gateway

The Gateway is one of the easiest and safest components to upgrade because it is stateless and rarely changes.

## Upgrading CMS and the RDS Schema

CMS applies RDS schema updates automatically using <a target="_blank" onclick="trackOutboundLink('https://flywaydb.org/')" href="https://flywaydb.org/">Flyway</a>.  This makes upgrading version quite 
easy but downgrading may require a restore from backup or other manual intervention.

## Upgrading Vault and Consul

Vault is the only Cerberus component that technically requires downtime during a deploy, 10-30 seconds, as a new leader
is elected (this is due to how Cerberus is currently using an ELB instead of service discovery for accessing Vault).

Vault and Consul upgrades should be tested before applying to production.  Incompatible configuration may prevent these
components from starting.  Be prepared to perform [Consul recovery](consul-recovery) if you make any mistake during an
upgrade.

## Upgrading the Dashboard

Use the `publish-dashboard` command to deploy a new dashboard.  The command simply downloads a release and uploads the
static files to an S3 bucket.

# Upgrading Specific Versions

* [New Consul Permissions](../../news/2017/05/04/new-consul-permissions.html) May 4, 2017
  * The base stack needs to be updated before applying the latest Consul AMI
* [Upgrading Vault and Consul](../../news/2017/04/19/upgrading-vault-and-consul.html) April 19, 2017
  * Major version upgrades for both Vault and Consul
* [New CloudFormation Parameters](../../news/2017/04/17/new-cloudformation-parameters.html) April 17, 2017
  * Applying the new CloudFormation templates and initializing the new required paramters
* [Upgrading Gateway Config](../../news/2017/03/17/upgrading-gateway-config.html) March 17, 2017
  * Deploying changes to NGINX configuration for environments created with CLI version older than v0.15.2
