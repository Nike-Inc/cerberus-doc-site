---
layout: documentation
title: What Is Cerberus
---

Cerberus solves a common problem encountered when running cloud applications: how to safely store and manage secrets 
(e.g. database passwords, API keys, etc.).

# Background

At Nike, we have a complex environment with many different applications, technology stacks, AWS accounts, and teams.  Cerberus
was developed in this environment to increase agility and decrease risk by securely managing secrets, like passwords
and API keys, as well as non-sensitive dynamic run-time properties, such as feature flags and logging levels.

# Overview

-  Uses HashiCorp's [Vault](architecture/vault) to manage the actual encryption at rest and to provide access controls.
-  Operationalized for AWS including a [CLI](administration-guide/lifecycle-management-cli), Cloud Formation templates, edge security, and IAM integration.
-  Includes a [Dashboard](user-guide/dashboard), a self-service Web UI, where teams can manage properties and access control.
-  Provides client libraries (e.g. Java, Node, Ruby) that can be used by Cloud applications (EC2 or Lambda) to retrieve properties at run-time.

<img src="../images/arch-diagrams/cerberus-core-components-hlo.png" />
Cerberus is a [composed API](architecture/rest-api)

Cerberus is a cloud native application.  It relies heavily on [AWS infrastructure](architecture/infrastructure-overview).  It would take significant work to 
enable it in other environments.

# What Cerberus is NOT

Cerberus is designed for storing application secrets such as passwords, API keys, and certificates. It is not meant to 
be a general purpose Key/Value store for storing any kind of data. It is not a replacement for data stores like 
Cassandra, DynamoDB, or Redis.