---
layout: documentation
title: Files in S3
---

These S3 Buckets are created when bringing up a Cerberus Environment:

* Dashboard bucket, e.g. `{envName}-base-{hash}-dashboardbucket-{hash}`
* Cerberus Config bucket, e.g. `{envName}-base-{hash}-cerberusconfigbucket-{hash}`
* Gateway CloudFront bucket, e.g. `{envName}-gateway-{hash}-cloudfrontbucket-{hash}`

# Dashboard Bucket

E.g. `{envName}-base-{hash}-dashboardbucket-{hash}`

The Dashboard bucket hosts the actual code of the [Dashboard](../user-guide/dashboard). It gets created by the 
[publish-dashboard](../administration-guide/creating-an-environment#dashboard) command which downloads a Dashboard
[release](https://github.com/Nike-Inc/cerberus-management-dashboard/releases) and uploads the contents of the .tar.gz
file.

# Cerberus Config Bucket

E.g. `{envName}-base-{hash}-cerberusconfigbucket-{hash}`

The Cerberus Config bucket contains configuration files that are copied to Cerberus Ec2 instances when
they are brought into service.  All sensitive configuration data is encrypted with KMS.

This bucket has the following folder structure:

```
/config - configuration files shared between multiple services
/consul
    /backups - back-up files for Consul
/data
    /cloud-front-log-processor - CloudFront Lambda config (e.g. rate limiting)
    /cms - CMS service config
    /consul - Consul service config
    /gateway - Gateway service config
    /vault - Vault service config
    /lambda - contains actual Lambda code
```

Each of these folders is explained below.

## Config folder

The files in this folder are create/updated by multiple commands while [creating an environment](../administration-guide/creating-an-environment).

```
/config
    environment.json - non-sensitive environment data
    secrets.json -  secrets for CMS, Consul, and Vault
```

The `enviornment.json` contains non-sensitive environment data, such as CloudFormation stack names:

{% highlight properties %}
{
  "az1" : "us-west-2a",
  "az2" : "us-west-2b",
  "az3" : "us-west-2c",
  "stack_map" : {
    "BASE" : "arn:aws:cloudformation:us-west-2:{accountId}:stack/{envName}-base-{hash}",
    "CONSUL" : "arn:aws:cloudformation:us-west-2:{accountId}:stack/{envName}-consul-{hash}",
    "VAULT" : "arn:aws:cloudformation:us-west-2:{accountId}:stack/{envName}-vault-{hash}",
    "CMS" : "arn:aws:cloudformation:us-west-2:{accountId}:stack/{envName}-cms-{hash}",
    "GATEWAY" : "arn:aws:cloudformation:us-west-2:{accountId}:stack/{envName}-gateway-{hash}",
    "LAMBDA" : "",
    "RDSBACKUP" : "",
    "CLOUD_FRONT_IP_SYNCHRONIZER" : ""
  },
  "server_certificate_id_map" : {
    "CONSUL" : "consul_{hash}",
    "VAULT" : "vault_{hash}",
    "CMS" : "cms_{hash}",
    "GATEWAY" : "gateway_{hash}"
  },
  "config_key_id" : "{hash}",
  "replication_bucket_name" : null,
  "cd" : false
}
{% endhighlight %}

## Consul Back-ups

Consul back-ups are organized in a self-documenting way.

```
/consul/backups
    /daily
        /ip-172.x.x.x
            consul_backup_{date}.tar.gz
    /hourly
        /ip-172.x.x.x
            consul_backup_{date}.tar.gz
    /weekly
        /ip-172.x.x.x
            consul_backup_{date}.tar.gz
```

## CloudFront Log Processor

```
/data
    /cloud-front-log-processor
        lambda-config.json
```

The `lambda-config.json` file is created with the `create-cloud-front-log-processor-lambda-config` command and
contains the settings from that command:

{% highlight properties %}
{
  "manual_white_list_ip_set_id" : "{hash}",
  "manual_black_list_ip_set_id" : "{hash}",
  "rate_limit_auto_black_list_ip_set_id" : "{hash}",
  "rate_limit_violation_blacklist_period_in_minutes" : 60,
  "request_per_minute_limit" : 100,
  "slack_web_hook_url" : "https://hooks.slack.com/services/{HASH}/{HASH}/{HASH}",
  "slack_icon" : "https://s3-us-west-2.amazonaws.com/cerberus-assets/cerberus-logo-500x500.png",
  "google_analytics_id" : "UA-55555555-5"
}
{% endhighlight %}

 
## Cerberus Management Service Configuration

The `/data/cms` folder contains files that are copied to the CMS instances when they are first brought into service.

```
/data
    /cms
        cms-ca.pem - Certificate Authority key
        cms-cert.pem - TLS Certificate
        cms-key.pem - Private Key
        cms-pubkey.pem - Public Key
        environment.properties - CMS settings
```

The PEM files are uploaded with the `upload-cert` command while [creating an environment](../administration-guide/creating-an-environment#certs).


The `environment.properties` file is generated with the `create-cms-config` command and contains the following settings:

{% highlight properties %}

# Vault address and token for CMS
vault.addr=
vault.token=

# Group that has admin permissios for managing CMS
cms.admin.group=

# ARN's with specific permissions
root.user.arn=
admin.role.arn=
cms.role.arn=

# JDBC connection settings
JDBC.url=
JDBC.username=
JDBC.password=

# Additional custom properties, e.g. settings for Auth Connector


{% endhighlight %}


## Consul

The `/data/consul` folder contains files that are copied to the Consul instances when they are first brought into service.

```
/data
    /consul
        consul-ca.pem - Certificate Authority key
        consul-cert.pem - TLS Certificate
        consul-client-config.json - Consul client configuration
        consul-key.pem - Private Key
        consul-pubkey.pem - Public Key
        consul-server-config.json - Consul server configuration
        vault-acl.json
```


The Consul configuration files are generated from these templates: 

| Template | Associated CLI Command | Documentation |
| -------- | ---------------------- | ------------- |
| [consul-client.json.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/consul-client.json.mustache) | `create-consul-config` | [Consul Config](https://www.consul.io/docs/agent/options.html) |
| [consul-server.json.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/consul-server.json.mustache) | `create-consul-config` | [Consul Config](https://www.consul.io/docs/agent/options.html) |
| [vault-acl.json.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/vault-acl.json.mustache) | `create-vault-acl` | [Vault ACL's](https://www.vaultproject.io/intro/getting-started/acl.html) |

The PEM files are uploaded with the `upload-cert` command while [creating an environment](../administration-guide/creating-an-environment#certs).


## Gateway Configuration

The `/data/gateway` folder contains files that are copied to the Gateway instances when they are first brought into service.

```
/data
    /gateway
        gateway.conf
        nginx.conf
```

These NGINX configuration files are generated from the templates
[nginx.conf.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/nginx.conf.mustache) and
[site-gateway.conf.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/site-gateway.conf.mustache).

## Vault Configuration

The `/data/vault` folder contains files that are copied to the Vault instances when they are first brought into service.

```
/data
    /vault
        vault-ca.pem - Certificate Authority key
        vault-cert.pem - TLS Certificate
        vault-config.json - Configuration for Vault
        vault-key.pem - Private Key
        vault-pubkey.pem - Public Key
```

Vault configuration is generated from the [vault.json.mustache](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/templates/vault.json.mustache)
template using the `create-vault-config` command and is [documented here](https://www.vaultproject.io/docs/config/).

The PEM files are uploaded with the `upload-cert` command while [creating an environment](../administration-guide/creating-an-environment#certs).

## WAF Lambdas

The `/data/lambda` folder contains actual Lambda code.

```
/data
    /lambda
        cf-sg-ip-sync.zip - the CloudFront SecurityGroup IP synchronizer Lambda
        waf.jar - the Cerberus CloudFront Lambda
```

The cf-sg-ip-sync.zip file is a Lambda created by Amazon for adding CloudFront IP's to the correct SecurityGroup.

The waf.jar is the actual [Cerberus CloudFront Lambda](https://github.com/Nike-Inc/cerberus-cloudfront-lambda) whose
configuration is stored under in the same S3 bucket under `/data/cloud-front-log-processor/lambda-config.json` and
that also uses the Gateway CloudFront Bucket.


# Gateway CloudFront Bucket

E.g. `{envName}-gateway-{hash}-cloudfrontbucket-{hash}`

```
{ID}.{DATE}.{HASH}.gz - CloudFront logs (many files)
rate_limiting_lambda_ip_blocking_data.json - current violators for the rate limiter
```
This bucket is used by the [Cerberus CloudFront Lambda](https://github.com/Nike-Inc/cerberus-cloudfront-lambda).


# References

* [Consul Config](https://www.consul.io/docs/agent/options.html)
* [Vault Config]((https://www.vaultproject.io/docs/config/))
* [Vault ACL's](https://www.vaultproject.io/intro/getting-started/acl.html)
* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/kms/')" href="https://aws.amazon.com/kms/">AWS Key Management Service (KMS)</a>
* <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/s3/')" href="https://aws.amazon.com/s3/">Amazon S3</a>
