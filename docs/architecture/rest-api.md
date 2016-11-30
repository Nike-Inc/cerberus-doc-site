---
layout: documentation
title: REST API
---

Cerberus is a composed API behind a reverse proxy that delegates to 3 services.

* `/dashboard*` goes to the S3 bucket and serves our [Dashboard](../user-guide/dashboard), a
  <a target="_blank" onclick="trackOutboundLink('https://facebook.github.io/react/')" href="https://facebook.github.io/react/">React</a> single-page application (SPA), that provides the UI for interacting with the other two services.
* `/v1/secret/*` goes to the <a target="_blank" onclick="trackOutboundLink('https://www.vaultproject.io/docs/secrets/generic/index.html')" href="https://www.vaultproject.io/docs/secrets/generic/index.html">Vault generic secret backend</a>.
* `/v1/auth/token/lookup-self` goes to the <a target="_blank" onclick="trackOutboundLink('https://www.vaultproject.io/docs/auth/token.html')" href="https://www.vaultproject.io/docs/auth/token.html">Vault auth backend</a>.
* `/v1/*` (everything else) goes to <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-management-service/blob/master/API.md')" href="https://github.com/Nike-Inc/cerberus-management-service/blob/master/API.md">Cerberus Management Service API</a>
  * The other key thing to note is that when you post to `/v1/auth/iam-role` the JSON payload you get back is an 
    encrypted KMS blob that requires 
    a <a target="_blank" onclick="trackOutboundLink('http://docs.aws.amazon.com/kms/latest/developerguide/programming-encryption.html')" href="http://docs.aws.amazon.com/kms/latest/developerguide/programming-encryption.html">decrypt call</a> to get the actual
    JSON payload defined in the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-management-service/blob/master/API.md')" href="https://github.com/Nike-Inc/cerberus-management-service/blob/master/API.md">API</a>.  See the 
    <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-healthcheck-lambda')" href="https://github.com/Nike-Inc/cerberus-healthcheck-lambda">health check lambda</a> for simple example code.

Please see the documentation for the underlying API you wish to work with.
    
<img src="../../images/arch-diagrams/cerberus-core-components-hlo.png" />

# References

*  <a target="_blank" onclick="trackOutboundLink('http://docs.aws.amazon.com/kms/latest/APIReference/Welcome.html')" href="http://docs.aws.amazon.com/kms/latest/APIReference/Welcome.html">KMS API Reference</a>
*  <a target="_blank" onclick="trackOutboundLink('http://docs.aws.amazon.com/kms/latest/developerguide/programming-top.html')" href="http://docs.aws.amazon.com/kms/latest/developerguide/programming-top.html">KMS Programming Guide</a>