---
layout: post
title: Upgrading Gateway Config
date:   2017-03-17 12:00:00 -0700
categories: news
---

Environments created with CLI version older than
[v0.15.2](https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases/tag/v0.15.2) should regenerate Gateway config 
using the [latest CLI](https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases).

Two minor changes have been made to the NGINX configuration:

1. Health-check now returns a content type and response body (more user friendly if you hit it from a browser)
1. Added a robots.txt to disallow crawling

<br />

To apply these changes to your environment:

1) Regenerate the gateway config with the same parameters used during installation.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-gateway-config \
    --hostname demo.cerberus-oss.io
    
2) Perform a rolling restart of gateway instances so they will re-download the latest configuration from S3.

