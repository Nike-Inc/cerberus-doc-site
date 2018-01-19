---
layout: documentation
title: High Availability
---

Cerberus is a cloud native application, designed to be failure indifferent, self-healing, and highly available.

See the [infrastructure overview](infrastructure-overview) for more information.

# Configuration

Configuration is stored in S3 and is managed with the CLI.  In our preferred configuration, the CLI will store copies
of the configuration in two regions for high availability.

# KMS

Secrets are encrypted using the Key Management Service (KMS) and the 'AWS Encryption SDK'.
Multiple Customer Master Keys (CMKs) are used to ensure multi-region availability of encrypted data.

# RDS

Amazon Aurora is used in a multiple availability zone configuration.

# Backups

Backups are automatically setup when a Cerberus environment is provisioned. RDS snapshots are used plus we've included
a command in our CLI for copying them cross region.

# References

*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/elasticloadbalancing/')" href="https://aws.amazon.com/elasticloadbalancing/">AWS Elastic Load Balancing (ELB)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/autoscaling/')" href="https://aws.amazon.com/autoscaling/">AWS Auto Scaling</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/kms/')" href="https://aws.amazon.com/kms/">AWS Key Management Service (KMS)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/introduction.html')" href="https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/introduction.html">AWS Encryption SDK</a>