---
layout: documentation
title: Security Features
---

# WAF

* The WAF automatically drops requests with incorrect request body size, SQL injection, and Cross Site Scripting (XSS).
* A rate limiting lambda is used to temporarily auto-block IPs exceeding Cerberus rate limits (based on AWS whitepaper: AWS Best Practices for DDoS Resiliency)
* IP Whitelisting and blacklisting are also available

# TLS

* In our testing, Cerberus received an A+ score from [SSLLabs](https://www.ssllabs.com/) (Dec 2017)
* TLS v1.2 is required by the Application Load Balancer (ALB) and for communication to the Cerberus Management Service (CMS)
* TLS certificate rotation is available via CLI command and can be done automatically (e.g. via Jenkins job or similar).
* Built-in automation for Let's Encrypt being used as the Certificate Authority (others can be used as well).

# HTTP Headers

* In our testing, Cerberus received an A+ score from [securityheaders.io](https://securityheaders.io) (Dec 2017)
* The following recommended headers are enabled
  * X-Frame-Options
  * X-Content-Type-Options
  * X-XSS-Protection
  * Content-Security-Policy
  * Referrer-Policy
  * Strict-Transport-Security

# Secrets Encryption

* Cerberus secrets are encrypted with the 'AWS Encryption SDK' using AES-GCM with an HMAC-based extract-and-expand key derivation function (HKDF), signing, and a 256-bit encryption key.
* The SDB path is stored in the Encryption Context for secrets and is validated by the system before decryption.
* Each SDB path is encrypted using a unique Data Key.
* Each time secrets are updated, a unique Data Key is generated.
* Multiple Customer Master Keys (CMKs) are used to ensure multi-region availability of encrypted data.
* Customer Master Keys (CMKs) are configured to auto-rotate annually
* Further, the encrypted payload is stored in encrypted RDS using AES-256.

# Secrets Meta-Data Encryption

* All secret meta data (generally non-sensitive) is stored in encrypted RDS using AES-256.

# Token Generation, Hashing, and Storage

* Tokens are 64 characters long (configurable) and generated using SecureRandom.
* Tokens are hashed using PBKDF2WithHmacSHA512 using a 256 key length and 100 iterations (all options configurable).
* Hash uses 64 byte salt
* Token hashes are stored in encrypted RDS using AES-256
* Tokens have a 1 hour TTL (configurable)
* Configuration validation is used to prevent accidental misconfiguration (e.g. min 64 characters, min 256 key length, min 100 iterations)

# Configuration Encryption

* Configuration is encrypted with the 'AWS Encryption SDK' using AES-GCM with an HMAC-based extract-and-expand key derivation function (HKDF), signing, and a 256-bit encryption key.
* Configuration is replicated in more than one region
* KMS keys for configuration are configured to auto-rotate annually.

# References

*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/kms/')" href="https://aws.amazon.com/kms/">AWS Key Management Service (KMS)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/introduction.html')" href="https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/introduction.html">AWS Encryption SDK</a>