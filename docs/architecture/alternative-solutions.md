---
layout: documentation
title: Alternative Solutions
---

Cerberus was developed because we did not find another solution that met our needs at the time.

Some of the options we looked at included:

# CyberArk Password Vault and AIM

[CyberArk](http://www.cyberark.com/) is a company that owns and licenses enterprise security solutions such as
the [Privileged Account Security Solution](http://www.cyberark.com/products/privileged-account-security-solutions/).


# Confidant

[Confidant](https://lyft.github.io/confidant/) is open source solution developed by Lyft that provides user-friendly 
storage and access to secrets in a secure way.  Uses KMS, IAM authentication, and Google OAuth.


# HashiCorp Vault with Consul backend

Cerberus was built on this technology, adding features we needed to operationalize it for our environment.

[Hashicorp](https://www.hashicorp.com/) also has an [enterprise Vault product](https://www.hashicorp.com/vault.html).