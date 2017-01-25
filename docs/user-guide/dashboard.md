---
layout: documentation
title: Dashboard
---

The Cerberus Dashboard is a Self-Service UI for managing secrets.

- Create new safe deposit boxes (SDB) for Applications or Shared secrets
- Modify ownership and access permissions for secrets
- Delete SDBs


# Screenshots

Single sign-on eliminates the need to manually create user accounts.

<img src="../../images/dashboard/login-screen.png" alt="Cerberus Dashboard Login screenshot" />

<br />

The Welcome Screen lists the SDBs you have access to and lets you add new ones.

<img src="../../images/dashboard/welcome-screen.png" alt="Cerberus Dashboard Welcome screenshot" />

<br />

Users can create their own safe deposit boxes for their applications.  Self-service eliminates the need for 
service tickets to administrators.

<img src="../../images/dashboard/create-new-safe-deposit-box-screen.png" alt="Cerberus Dashboard new SDB screenshot" />

<br />

Users can add [Vault](../architecture/vault) paths for their applications as well as view and modify properties.

<img src="../../images/dashboard/add-new-vault-path-screen.png" alt="Cerberus Dashboard Vault screenshot" />

<br />

Editing a Safe Deposit Box (SDB) allows users to add and remove permissions.

<img src="../../images/dashboard/edit-safe-deposit-box-screen.png" alt="Cerberus Dashboard edit SDB screenshot" />

Only the owner is allowed to modify permissions or to delete the SDB.

<br />

# Implementation

The dashboard is implemented as a <a target="_blank" onclick="trackOutboundLink('https://facebook.github.io/react/')" href="https://facebook.github.io/react/">React</a> single-page application (SPA) that interacts with the
[composed REST API](../architecture/rest-api).  It is stored in an [S3 bucket](../architecture/infrastructure-overview)
that gets setup using the [lifecycle management CLI](../administration-guide/lifecycle-management-cli).

# References

*  <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-management-dashboard')" href="https://github.com/Nike-Inc/cerberus-management-dashboard">Cerberus Management Dashboard Github</a>
*  <a target="_blank" onclick="trackOutboundLink('https://facebook.github.io/react/')" href="https://facebook.github.io/react/">React JavaScript Library</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/s3/')" href="https://aws.amazon.com/s3/">Amazon S3</a>