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

The <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-cloudfront-lambda')" href="https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-cloudfront-lambda">rate limiting lambda</a> is configured to auto-block
IPs making more than a maximum requests per minute (configurable).  If you are using any NAT boxes, you will need to
consider the aggregated traffic when you think about the limits or you will want to whitelist any NAT box IP addresses.

Request limits will vary by organization and use case but a good rule of thumb would be to make less than 
100 requests per hour per IP.

# Request Body Size

When writing data to Cerberus the request body size should be less than 256 KB.

# KMS Keys

Cerberus lazily creates a KMS key for every unique configured IAM role the first time they authenticate.
By default Amazon limits the number of KMS keys per region per account to 1000. 