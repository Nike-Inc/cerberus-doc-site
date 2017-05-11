---
layout: post
title: New Consul Permissions
date:   2017-05-04 12:00:00 -0700
categories: news
---

The latest Consul AMIs need additional permissions due to improvements in the upstart scripts.

Before deploying the latest Consul AMIs, use the CLI (v1.3.0 or newer) to update the base stack, e.g. `update-stack --stack-name base --overwrite-template`.

This can be done any time and it is safe to run this command more than once.
