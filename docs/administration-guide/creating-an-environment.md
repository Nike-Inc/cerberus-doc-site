---
layout: documentation
title: Creating a Cerberus Environment
---

The most difficult part of setting up a Cerberus environment is getting the certificates and keys setup correctly. This
is the most common cause of errors.  Otherwise the process is very automated and easy to traverse.

Note: Many of the commands complete quickly while some of the CloudFormation steps may take an hour to complete.

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

## Configure a Hosted Zone in AWS

Create a Hosted Zone in AWS (under the Route 53 console).

<a name="certs"></a>

## Create a Certificate for the Cerberus Environment

Create a certificate with the Subject Name and Subject Alternative Names in the following format:

    [ENVIRONMENT NAME].[PUBLIC DOMAIN]
    origin.[ENVIRONMENT NAME].[PUBLIC DOMAIN]
    vault.[REGION].[ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]
    consul.[REGION].[ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]
    cms.[REGION].ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]

An example using the Cerberus OSS Demo:

    demo.cerberus-oss.io
    origin.demo.cerberus-oss.io
    vault.us-west-2.demo.internal.cerberus-oss.io
    consul.us-west-2.demo.internal.cerberus-oss.io
    cms.us-west-2.demo.internal.cerberus-oss.io

Here is a breakdown of what each Subject Name will be used for...

The following names are in a public hosted zone in Route 53:
```
demo.cerberus-oss.io
origin.demo.cerberus-oss.io
```

The top level record `demo.cerberus-oss.io` will point to CloudFront, which serves as the entry point for users.
The origin `origin.demo.cerberus-oss.io` record will point to the public facing ELB for the Gateway stack. Although the
gateway ELB is public facing, it is given a Security Group that only allows access to CloudFront IP addresses.

The rest of the subject names are in a private hosted zone and used by the ELBs to communicate with various AutoScaling
Groups in the VPC:
```
vault.us-west-2.demo.internal.cerberus-oss.io
consul.us-west-2.demo.internal.cerberus-oss.io
cms.us-west-2.demo.internal.cerberus-oss.io
```

### Creating a Certificate using LetsEncrypt

<a target="_blank" onclick="trackOutboundLink('https://letsencrypt.org/')" href="https://letsencrypt.org/">LetsEncrypt</a> is a free, automated, open Certificate Authority. This is a great option if your
company does not have a defined process for creating certificates.

To create a certificate for Cerberus, make sure to create your A records in the AWS Console (example CNAMEs above).
These A records should point to a machine running a server (e.g. NGINX).

Then, use <a target="_blank" onclick="trackOutboundLink('https://certbot.eff.org/')" href="https://certbot.eff.org/">cert-bot</a> and run the cert-bot wizard.

At the end, I had the following files in `/etc/letsencrypt/live/demo.cerberus-oss.io`:

    cert.pem  chain.pem  fullchain.pem  privkey.pem

Then you should run the following commands

    # extract the public key
    openssl rsa -in privkey.pem -pubout > pubkey.pem
    # rename private key to what the CLI expects
    mv privekey.pem key.pem
    # rename the CA chain to what the CLI expects
    # AWS IAM did not like the full chain
    mv chain.pem ca.pem

Take note of the local directory where these files are stored as you will need them in the steps below.
Recommended: Export the directory path to environment variable `CERBERUS_CERT_DIR` and reference it.

**Make sure to delete the A records you created for the cert generation.**

### Creating a Certificate using Venafi

If you are using Venafi, after creating the certificate in the UI,

1. Download the Certificate
   1. Choose DER format (later this file will be used to import into your Java trust store)
1. Download the Certificate again
   1. Choose PEM/OpenSSL format
   1. Include the Root Chain and Private Key by checking all of the checkboxes
   1. Choose the default Chain Order "End Entity First"
   1. Enter a pass phrase
1. The resulting download has four sections, break it up into three files:
   1. Section 1 goes in a file named cert.pem
   1. Section 2 and 3 go in a file named ca.pem
   1. Section 4 goes in a file named privkey.pem
1. Run the following commands to extract the private and public keys (you will be prompted for the pass phrase entered earlier):
   1. `openssl rsa -in privkey.pem -pubout > pubkey.pem`
   1. `openssl rsa -in privkey.pem -out key.pem`

### Make Certificate Usable by Cerberus

Once the certificate is created, we will need to ensure the following files are together in one directory for the CLI
to reference:

file       | purpose
---------- | ---------------------------------
pubkey.pem | the public key
key.pem    | the private key
ca.pem     | the certificate authority key
cert.pem   | the cert

<a name="add-ca"></a>

### Add the CA to your java trust store.

You will most likely need to add your CA to the Java trust store, unless the JVM trusts it already by default, e.g.

    keytool -import -keystore PATH_TO_JDK\jre\lib\security\cacerts -storepass changeit -noprompt -trustcacerts -alias [ALAIS] -file PATH_TO_DOWNLOADS\[CA].der

Find the current Java on MacOS with `/usr/libexec/java_home`.

## Generate a SSH Key Pair for your Cerberus instances using the AWS Console

Go to the EC2 panel and navigate to Key Pairs and generate a new key pair(s) to use for the Cerberus environment.
For the demo I will use one key-pair for all the Cerberus component instances, but you can have a different key pair for
each core component if you wish.

## Create a YAML file that defines properties for your Cerberus environment

Here is an example Cerberus environment [YAML properties file](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/resources/example-standup.yaml).

Recommended: Name the YAML properties file after the environment name (e.g. dev.yaml, test.yaml, prod.yaml, etc.)


## Create the VPC for the Cerberus Environment and set up the base resources needed for the environment
The following properties are required to be set in your YAML:

Property                       | Notes
-------------------------------|------
admin-role-arn                 | an ARN for an IAM Role that will be given permission to administrate the KMS keys created by the CLI. If you have SSO integrated into AWS IAM and there is a role that admins get use that role, or else just create a new role for this.
vpc-hosted-zone-name           | This is the private hosted zone that ELBs in the Cerberus env VPC will use. in our demo case we would use `demo.internal.cerberus-oss.io`
owner-email                    | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter                     | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

Here is the command to run with our demo values, make sure to replace the values with your own.

    cerberus --debug -f /path/to/test.yaml create-base

**This command will take a long time to run. If you're worried that the CLI has frozen, you can check the CloudFormation
panel in the AWS Console for confirmation.**

This command creates a VPC for the Cerberus Environment including all needed networking resources: IAM Roles, S3 Buckets,
Bucket policies, and the RDS Instance needed for the Cerberus Management Service. See the
<a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/smaas-cf/smaas/vpc-and-base.py')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/smaas-cf/smaas/vpc-and-base.py">VPC and Base CloudFormation Troposphere</a>
and <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/java/com/nike/cerberus/operation/core/CreateBaseOperation.java')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/java/com/nike/cerberus/operation/core/CreateBaseOperation.java">Create Base Command Operation</a> for more information.


## Whitelist CIDRs and PORTS
This command can be used to whitelist corporate proxy boxes or even just your current IP.
This is a destructive command that overwrites any rules that exist on the security group
for VPC ingress.

Some commands to stand up Cerberus will require direct network access to EC2 instances. You can accomplish this by
whitelisting your current IP address for port 443, 8080, 8200, 8400, 22, while you stand up the environment, or by
using a proxy.

Quick tips for using CIDR notation: `0.0.0.0/0` is the entire internet,
`192.168.0.9/32` is the single IPV4 address of `192.168.0.9`

Here is an example YAML section for whitelisting CIDRs:

    vpc-access-whitelist:
      ports:
        - 443
        - 8080
        - 8200
        - 8500
        - 8400
        - 22
      cidrs:
        - 50.39.106.150/32
        - 104.32.51.64/32

Run the following command once your whitelist properties are configured:

    cerberus --debug -f /path/to/test.yaml whitelist-cidr-for-vpc-access

If you are using NAT boxes, we recommend whitelisting their IP addresses, so that aggregated traffic
does not cause the NATs to be blacklisted.

## Upload Consul Certificate

Upload the Consul Certificate

    cerberus --debug \
    -f /path/to/test.yaml \
    upload-cert \
    --stack-name consul

## Create Consul Config

Create the config needed for consul to run

    cerberus --debug -f /path/to/test.yaml create-consul-config


## Create Vault ACL for Consul

Create an ACL for Vault to have perms to use Consul

    cerberus --debug -f /path/to/test.yaml create-vault-acl


## Create Consul Cluster

Create the Consul Cluster. The following properties are required in your YAML:

Property                       | Notes
-------------------------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `consul` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug -f /path/to/test.yaml create-consul-cluster

This command creates a Consul cluster (using the AMI baked in the previous steps above). Consul starts automatically when
the instance is loaded and downloads the encrypted configuration file that we generate. AWS Tags are then used to find
other Consul clients in the same environment and join their cluster, or to create a new Consul cluster if no other
clients are found.

The Consul instances are configured to automatically back up their data to S3. Feel free to look through the
<a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-consul-puppet-module')" href="https://github.com/Nike-Inc/cerberus-consul-puppet-module">Cerberus Consul Puppet Module</a> to learn more about how we configure
Consul.

## Upload Vault Certificate

Upload the Vault Certificate

    cerberus --debug \
    -f /path/to/test.yaml \
    upload-cert \
    --stack-name vault


## Create Vault Config

Create the vault configuration that will enable TLS and have the consul config

    cerberus --debug -f /path/to/test.yaml create-vault-config


## Create Vault Cluster

Property      | Notes
--------------|-------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `vault` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug -f /path/to/test.yaml create-vault-cluster

This will create an ASG of Vault instances that will automatically download our generated configuration and join the
Consul cluster in client mode. Once a Vault instance is initialized for an environment, it has the ability to unseal
itself by retrieving the encrypted data it needs from S3, calling KMS decrypt, and invoking the unseal endpoint on
itself.

Allowing Vault instances to unseal themselves makes the entire cluster resistant to failure because if one instance
becomes unhealthy or shuts down, then the ASG will spawn a new instance that can bootstrap itself. Feel free to look
through the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-vault-puppet-module')" href="https://github.com/Nike-Inc/cerberus-vault-puppet-module">Cerberus Vault Puppet Module</a> to learn more
about how we configure Vault.

## Initialize Vault
Next we need to initialize Vault which requires talking directly to the instances in the VPC, so if you need to use a
proxy you can do so by adding a YAML block to your Cerberus environment YAML file:

    proxy-config:
      host: localhost
      port: 9000
      # [DIRECT, HTTP, SOCKS]
      type: SOCKS

after the region, but before the 'init-vault-cluster' command.

** **Note: You may need to wait a few minutes, after creating the Vault cluster, before you run this command.**

    cerberus --debug -f /path/to/test.yaml init-vault-cluster

Errors at this step may be from:

1. Not waiting a few minutes after `create-vault-cluster` before trying to initialize it
1. SSL Handshake Errors from not importing the CA for your certificate provider to your Java trust store (<a href="#add-ca">see above</a>).
1. A proxy or firewall issue.
1. Other issue.  See Vault and Consul logs.

## Unseal Vault

Now we need to manually unseal vault for the first time. Instances will unseal themselves after future updates and
auto scaling events.

Unsealing the Vault instances requires talking directly to the instances in the VPC, so if you need to use a proxy you
can do so by adding a YAML block to your environment properties YAML file:

    proxy-config:
      host: localhost
      port: 9000
      # [DIRECT, HTTP, SOCKS]
      type: SOCKS
      
** Note: You only need to place this in your YAML one time. Also, this is a standalone block and should not be nested
in with any of the other components

then, run this command

    cerberus --debug -f /path/to/test.yaml unseal-vault-cluster

Now, Vault should be ready to use. Next, run the vault-health command to verify that everything's working properly.
Again, this command talks directly to the instances, so include proxy information in the YAML if necessary:

    cerberus --debug -f /path/to/test.yaml vault-health

We expect to see 3 instances that are all "Sealed: false" and 1 instance that is "Standby: false," (this is the
elected leader).

## Load Default Policies in Vault

Load the default policies into Vault. This command talks directly to vault instances, so provide proxy information
in the YAML if necessary.

    cerberus --debug -f /path/to/test.yaml load-default-policies


## Upload CMS Certificate

    cerberus --debug \
    -f /path/to/test.yaml \
    upload-cert \
    --stack-name cms


## Create CMS Vault Token

The Managment Service (CMS) uses a Vault token to create additional Vault tokens for users and AWS Resources
when they authenticate through CMS. Provide proxy information if necessary.

    cerberus --debug -f /path/to/test.yaml create-cms-vault-token

## Create CMS Config

The CMS config is an encrypted properties file that contains the Vault token for CMS as well as the Auth Connector
information. Supported Auth Connectors currently only include OneLogin, and Okta, but others can be added easily.

The following properties are required for all connectors:

Property    | Notes
------------|------
admin-group | The group that admin users belong to, admin users have elevated privileges in the API.

** Note: You can add arbitrary properties that will get written to the CMS configuration file by adding a
`properties` block under the `management-service` section of your YAML properties file:

```
properties:
    - cms.auth.connector=com.nike.cerberus.auth.connector.onelogin.OneLoginAuthConnector
    - auth.connector.onelogin.api_region=us
    - auth.connector.onelogin.client_id=123
    - auth.connector.onelogin.client_secret=213
    - auth.connector.onelogin.subdomain=nike
```

CMS requires the property `cms.auth.connector` with the fully qualified class name of the Auth connector
implementation, e.g. `com.nike.cerberus.auth.connector.onelogin.OneLoginAuthConnector`.  The example below
shows other required properties for OneLogin.

For more information about auth connectors, including configuration options, using Okta, or writing your own custom auth connector, please
see the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-management-service/')" href="https://github.com/Nike-Inc/cerberus-management-service/">CMS</a> project.

Run the following command to create the CMS Config:

    cerberus --debug -f /path/to/test.yaml create-cms-config


## Create CMS Cluster

Next, stand up the CMS cluster using the AMI (built earlier).

Property      | Notes
--------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `cms` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug -f /path/to/test.yaml create-cms-cluster


## Publish Dashboard

Upload the Single Page App to S3

    cerberus --debug -f /path/to/test.yaml publish-dashboard

## Upload Gateway Certificate

Upload the Certs for the Gateway ELB

    cerberus --debug \
    -f /path/to/test.yaml \
    upload-cert \
    --stack-name gateway


## Create Gateway Config

Create the reverse proxy config for NGINX

    cerberus --debug -f /path/to/test.yaml create-gateway-config

## Upload the Cloud Front Log Processing Lambda to S3

Upload the jar for the Lambda to S3

    cerberus --debug -f /path/to/test.yaml publish-lambda --lambda-name WAF

In the above command, `WAF` is a String Enum name.

## Create Gateway Cluster

Next, create the reverse proxy that routes the unified API.

Property       | Notes
---------------|------
hosted-zone-id | This will be the Hosted Zone id of the Route 53 Hosted Zone that has your [PUBLIC DOMAIN] in my case it would be the hosted zone id for cerberus-oss.io.
instance-size  | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name  | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id         | The ami-id that for `gateway` that you created earlier.
owner-group    | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email    | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter     | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug -f /path/to/test.yaml create-gateway-cluster

**This command will take a long time to run. If you think the CLI has frozen, you can check the CloudFormation
panel in the AWS Console for confirmation.**

## Create the Cloud Front Log Processing Lambda Config

Now that the Gateway stack is created, the Cloud Front Log Processing Lambda needs to be configured. This Lambda currently
only handles rate limiting, so the limits need to be defined here.

At this time there will be a Manual Whitelist and a Manual Blacklist IP Set that you can add or remove CIDRs to in the
AWS Dashboard. Just take a look at the resources that the gateway CloudFormation stack created to hunt these down.

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


    cerberus --debug \
    -f /path/to/test.yaml \
    create-cloud-front-log-processor-lambda-config


## Upload the Lambda to S3 for the CloudFront Security Group IP Synchronizer

The Origin ELB is setup behind CloudFront which is configured to filter according to the Manual Whitelist,
Manual Blacklist, Auto Blacklist IPs, and other basic edge security rules. Thus, we do not want to allow requests to
bypass the WAF and talk to the Origin directly.
 
Create a Lambda that watches the WAF whitelist and blacklist, and publishes a message to an SNS topic whenever a list
is updated:

    cerberus --debug \
    -f /path/to/test.yaml \
    publish-lambda \
    --lambda-name CLOUD_FRONT_SG_GROUP_IP_SYNC

In the above command, `CLOUD_FRONT_SG_GROUP_IP_SYNC` is a String Enum name.

## Create the Lambda function and subscribe it to the AWS IP change topic

Create a Lambda that subscribes to the SNS topic (from the previous step) and auto-updates (properly tagged) ELB
Security Groups to allow or deny ingress based on the WAF whitelist/blacklist:

    cerberus -e demo
    -f /path/to/test.yaml \
    create-cloud-front-security-group-updater-lambda
