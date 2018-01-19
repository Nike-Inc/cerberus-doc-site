---
layout: documentation
title: Files in S3
---

These S3 Buckets are created when bringing up a Cerberus Environment:

* Cerberus Config bucket(s), e.g. `{envName}-cerberus-config-cerberusconfigbucket-{hash}`, multiple copies may be created in different regions for redundancy. 
* Load Balancer log bucket, e.g. `{envName}-cerberus-load-balancer-alblogbucket-{hash}`

# Cerberus Config Bucket

E.g. `{envName}-cerberus-config-cerberusconfigbucket-{hash}`

The Cerberus Config bucket contains configuration files that are copied to Cerberus Ec2 instances when
they are brought into service.  All sensitive configuration data is encrypted with the AWS Encryption SDK
using KMS.

This bucket has the following folder structure:

```
/certificates - TLS certificates
    /acme - Folder for the Let's Encrypt provider
        account-private-key-pkcs1.pem - Key needed to revoke Certificates in Let's Encrypt
    /cerberus_{envName}_{hash} - one or more folders
        /ca.pem - Certificate Authority key
        /cert.pem - TLS Certificate
        /key.pem - Private Key
        /pkcs8-key.pem - Public key in pkcs8 format (format needed by Netty)
        /cms-pubkey.pem - Public Key
/cms - Cerberus Management Service
    /environment.properties - Settings for the CMS service
environment.json
```

## Load Balancer log bucket

E.g. `{envName}-cerberus-load-balancer-alblogbucket-{hash}`

This bucket has the following folder structure:

```
/AWSLogs
    /{accountId}
        /elasticloadbalancing
            /{region}
                /{year}
                    /{month}
                        /{day}
        /ELBAccessLogTestFile
rate_limit_processor_blacklist_data.json
```


# References

* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/s3/')" href="https://aws.amazon.com/s3/">Amazon S3</a>
