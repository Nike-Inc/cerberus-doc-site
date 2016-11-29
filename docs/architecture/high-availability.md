---
layout: documentation
title: High Availability
---

Cerberus is a cloud native application, designed to be failure indifferent, self-healing, and highly available.  Most 
components of Cerberus are update-able with zero downtime, but there are a few key maintenance tasks that may incur 
downtime although these outages can be measured in just a few minutes.

See the [infrastructure overview](infrastructure-overview) for more information.


# Backups

Backups are automatically setup when a Cerberus environment is provisioned. We take hourly, daily and weekly 
backups of the data to S3.  These backups are for the unexpected and extreme cases where the entire data store cluster
is lost.


# Data Recovery

A manual process is needed to restore the data store cluster in the event that the cluster is lost entirely.  The
process of restoring from backup takes up to 30 minutes.  The likely hood of this happening is extremely low as the
cluster is fault tolerant and self healing in the event that a node goes bad.


# References

*  <a target="_blank" onclick="trackOutboundLink('https://www.vaultproject.io/docs/internals/high-availability.html')" href="https://www.vaultproject.io/docs/internals/high-availability.html">Vault High Availability</a>
*  <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/index.html')" href="https://www.consul.io/docs/index.html">Consul Documentation</a>
*  [AWS Elastic Load Balancing (ELB)](https://aws.amazon.com/elasticloadbalancing/)
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/autoscaling/')" href="https://aws.amazon.com/autoscaling/">AWS Auto Scaling</a>