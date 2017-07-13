---
layout: post
title: Upgrading to Raft Protocol Version 3
date:   2017-07-11 00:00:00 -0700
categories: news
---

Raft 3 is needed to take advantage of the new [Autopilot](https://www.consul.io/docs/guides/autopilot.html) features in Consul.

Before upgrading to Raft Protocol Version 3 we recommend upgrading to Consul 0.8.5 (or latest 0.8.x release).
Raft 3 requires Consul 0.8.x but with Raft 3 [recovery with peers.json doesn't work prior to 0.8.4](https://github.com/hashicorp/consul/issues/3003).

Consul 0.8.3 upgrades smoothly to 0.8.5 by simply deploying a new AMI.

Upgrade Directions:

1. Ensure Consul 0.8.5 is running on all nodes.  Remember Consul clients run on the Vault nodes.
2. Run `update-consul-config` with CLI version 3.0.0 or newer to make the config change for raft protocol 3.
3. Restart all Consul server nodes.
4. Restart all Consul clients on the Vault nodes.

References:

- [https://www.consul.io/docs/guides/autopilot.html](https://www.consul.io/docs/guides/autopilot.html)
- [https://www.consul.io/docs/upgrade-specific.html](https://www.consul.io/docs/upgrade-specific.html)