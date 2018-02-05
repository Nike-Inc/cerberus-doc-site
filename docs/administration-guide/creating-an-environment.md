---
layout: documentation
title: Creating a Cerberus Environment
---

Creating a Cerberus environment is an automated processes and can be completed in as little as 30 minutes.


## Run Cerberus in its own AWS Account

Due to how Cerberus uses KMS as part of its [authentication](/cerberus/docs/architecture/authentication) we strongly
recommended running Cerberus in its own account for security reasons.  Running Cerberus in its own account prevents
services from being able to impersonate each other.  In the future, we hope to remove this limitation.


## Create Cerberus AMIs

Clone or download the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-util-scripts')" href="https://github.com/Nike-Inc/cerberus-util-scripts">Cerberus Utility Script</a> project and follow
the README to create AMIs for Consul, Vault, Gateway and Cerberus Management Service.


## Configure the Lifecycle Management CLI

Ensure you have a Java 8 JRE with Java Cryptography Extension (JCE) Unlimited
Strength Jurisdiction Policy installed and available on your path (Note: a second download is required).

Download the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases/latest')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases/latest">Cerberus Lifecycle CLI</a>
(both the cerberus shell script and jar) to some location like `~/Applications/cerberus` and setup environment variables:

```bash
export CERBERUS_HOME=~/Applications/cerberus
export PATH=$PATH:$CERBERUS_HOME
```

Recommended: Install the AWS CLI. This is not required to stand up a Cerberus environment, but it is required
to delete one. Then configure your AWS credentials via the CLI command: `aws configure`.

If you do not wish to install the AWS CLI, see
<a target="_blank" onclick="trackOutboundLink('http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html')" href="http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html">Working with AWS Credentials</a>
for alternative ways to supply credentials for the Cerberus Lifecycle CLI. We use the default credential provider chain with
an added STSAssumeRoleSessionCredentialsProvider (so that build systems can assume a role). You can allow cerberus to
assume a role by setting environment variables `CERBERUS_ASSUME_ROLE_ARN` and `CERBERUS_ASSUME_ROLE_EXTERNAL_ID`.


## Generate a SSH Key Pair for your Cerberus instances using the AWS Console

Go to the EC2 panel and navigate to Key Pairs and generate a new key pair(s) to use for the Cerberus environment.


## Create the Cerberus Environment

Copy and modify the [example-standup.yaml](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/test/resources/environment.yaml) and pass it as a parameter to the create environment command.

```cerberus -f /path/to/yaml create-environment``` 

Recommended: Name the YAML properties file after the environment name (e.g. dev.yaml, test.yaml, prod.yaml, etc.)

TLS Certificates can be automatically created for you by the CLI, using Let's Encrypt, or can be manually created using
another vendor such as [Venafi](venafi-certs).


## Deploy the cerberus-log-processor-lambda

This lambda monitors the ALB logs and uses the AWS WAF to enforce a configurable rate limit.

The following properties are required:

Property                                     | Notes
---------------------------------------------|------
rate-limit-per-minute                        | The number of requests per minute an IP can make before its added to the auto blacklist IP Set
rate-limit-violation-block-period-in-minutes | The number of minutes an IP will be blocked for violating the rate limit

(Optionally) configure the Lambda to message slack when CIDRs are added or removed from the Auto Block IP set. To do so,
add the following properties in your YAML:

Property           | Notes
-------------------|------
slack-web-hook-url | Your slack webhook url.
slack-icon         | A URL to a custom icon, you can leave this off to use the default icon.

See the [github project](https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-log-processor-lambda) for more information.

There is a Manual Whitelist and a Manual Blacklist IP Set that you can add or remove CIDRs to in the
WAF section of the AWS console.


## Deploy the healthcheck lambda

The healthcheck lambda can be used to monitor a Cerberus system.

See the [github project](https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda) for more information.
