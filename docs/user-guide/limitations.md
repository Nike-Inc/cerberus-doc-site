---
layout: documentation
title: Limitations
---

# Key / Value Store

Cerberus is designed for storing application secrets such as passwords, API keys, and certificates.  It is not
meant to be a general purpose Key/Value store for storing any kind of data. It is not a replacement for applications 
like Cassandra, DynamoDB, or Reddis.

# Requests per Second

When configuring an [Archaius polling client](archaius) choose a reasonable interval based on your environment.
For example,

-  1000 clients polling every 5 seconds results in a possibly excessive ~200 requests per second
-  5000 clients polling every 5 minutes results in a reasonable ~17 requests per second

The [rate limiting lambda](https://github.com/Nike-Inc/cerberus-cloudfront-lambda) is configured to auto-block
IPs making more than a maximum requests per minute (configurable).

Request limits will vary by organization and use case but a good rule of thumb would be to make less than 
100 requests per hour per IP.

# Request Body Size

When writing data to Cerberus the request body size should be less than 256 KiB.

# Payload Size

There is currently a 4KiB limit.  This has been sufficient thus far but can be increased in the future.