---
layout: documentation
title: Alternative Solutions
---

Cerberus was developed because we did not find another solution that met our needs at the time.

Here are some other options you may want to consider:

# AWS Parameter Store

[Parameter Store](https://aws.amazon.com/ec2/systems-manager/parameter-store/) is a feature of [Amazon EC2 Systems Manager](https://aws.amazon.com/ec2/systems-manager/)
that was released about the same time as Cerberus.

# CyberArk Password Vault and AIM

<a target="_blank" onclick="trackOutboundLink('http://www.cyberark.com/')" href="http://www.cyberark.com/">CyberArk</a> is a company that owns and licenses enterprise security solutions such as
the <a target="_blank" onclick="trackOutboundLink('http://www.cyberark.com/products/privileged-account-security-solutions/')" href="http://www.cyberark.com/products/privileged-account-security-solutions/">Privileged Account Security Solution</a>.

# Confidant

<a target="_blank" onclick="trackOutboundLink('https://lyft.github.io/confidant/')" href="https://lyft.github.io/confidant/">Confidant</a> is open source solution developed by Lyft that provides user-friendly 
storage and access to secrets in a secure way.  Uses KMS, IAM authentication, and Google OAuth.

# HashiCorp Vault with Consul backend

Cerberus was built on this technology, adding features we needed to operationalize it for our environment.

<a target="_blank" onclick="trackOutboundLink('https://www.hashicorp.com/')" href="https://www.hashicorp.com/">Hashicorp</a> also has an <a target="_blank" onclick="trackOutboundLink('https://www.hashicorp.com/vault.html')" href="https://www.hashicorp.com/vault.html">enterprise Vault product</a>.

# Credstash

[Credstash](https://github.com/fugue/credstash) is an easy to use credential management and distribution system that uses AWS Key Management Service (KMS) and DynamoDB.

# S3 with Server Side Encryption

Some people simply store credentials in [S3 with SSE](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingKMSEncryption.html)
which can be a viable option with the right policies in place.
