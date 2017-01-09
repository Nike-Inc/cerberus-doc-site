---
layout: documentation
title: Creating a Cerberus Environment
---

The most difficult part of setting up a Cerberus environment is getting the certificates and keys setup correctly. This
is the most common cause of errors.  Otherwise the process is very automated and well tested.

Note: many of the commands complete quickly while some of the CloudFormation steps may take an hour to complete.

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

You may want to install the AWS CLI. It is not required for standing up an environment, but it is required for deleting
an environment. Then configure your AWS credentials via the CLI command: `aws configure`.

If you do not wish to install the AWS CLI, see
<a target="_blank" onclick="trackOutboundLink('http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html')" href="http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html">Working with AWS Credentials</a> for
alternative ways to supply credentials for the Cerberus Lifecycle CLI. We use the default credential provider chain with
an added STSAssumeRoleSessionCredentialsProvider (so that build systems can assume a role). You can allow cerberus to
assume a role by setting environment variables `CERBERUS_ASSUME_ROLE_ARN` and `CERBERUS_ASSUME_ROLE_EXTERNAL_ID`.

## Configure a Hosted Zone for your AWS account.

Ensure that you have a Hosted Zone configured in AWS (under Route 53 console).

## Create a Certificate for the Cerberus Environment

Ensure that you have have created a certificate with the Subject Name and Subject Alternative Names in the following
format:

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

Take note of the local dir where you have these files as you will need them below.
I am lazy so I am going to export the dir to `CERBERUS_CERT_DIR` and reference it via the env var.

**Make sure to delete the A records you created for the cert generation.**

### Make Certificate Usable by Cerberus

Once the certificate is created, we will need to ensure the following files are together in one directory for the CLI
to reference:

file       | purpose
---------- | ---------------------------------
pubkey.pem | the public key
key.pem    | the private key
ca.pem     | the certificate authority key
cert.pem   | the cert
  
Venafi will let you download a cert as an OpenSSL pem file with the entity first.
If you have a single pem you will need to separate the cert section into `cert.pem` and copy the ca section (should be
two components) to `ca.pem`.

Then, run the following commands to extract the private and public keys:

    openssl rsa -in privkey.pem -pubout > pubkey.pem  
    openssl rsa -in privkey.pem -out key.pem

<a name="add-ca"></a>

### Add the CA to your java trust store.

More likely than not you will need to add your CA to the Java trust store, if it is not trusted by Java by default

** **Let's Encrypt is not trusted by Java in the default trust store, and needs to be added, I followed the directions
outlined <a target="_blank" onclick="trackOutboundLink('http://stackoverflow.com/a/37969672/770134')" href="http://stackoverflow.com/a/37969672/770134">here in this stack overflow answer</a>**

When you have the CA, you can run something like the following.

    keytool -import -keystore PATH_TO_JDK\jre\lib\security\cacerts -storepass changeit -noprompt -trustcacerts -alias [ALAIS] -file PATH_TO_DOWNLOADS\[CA].der

## Generate a SSH Key Pair for your Cerberus instances using the AWS Console

Go to the EC2 panel and navigate to Key Pairs and generate a new key pair or pairs to use for the Cerberus environment.
For the demo I will use one key-pair for all the Cerberus component instances, but you can have a different key pair for
each core component if you wish.

## Create the VPC for the Cerberus Environment and set up the base resources needed for the environment
You will need to supply the following parameters

Parameter                      | Notes
-------------------------------|------
admin-role-arn                 | an ARN for an IAM Role that will be given permission to administrate the KMS keys created by the CLI. If you have SSO integrated into AWS IAM and there is a role that admins get use that role, or else just create a new role for this.
vpc-hosted-zone-name           | This is the private hosted zone that ELBs in the Cerberus env VPC will use. in our demo case we would use `demo.internal.cerberus-oss.io`
owner-email                    | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter                     | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).
        
Here is the command to run with our demo values, make sure to replace the values with your own.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-base \
    --admin-role-arn [ADMIN ARN] \
    --vpc-hosted-zone-name demo.internal.cerberus-oss.io \
    --owner-email no-op@no-op.com \
    --costcenter no-op
    
**This command will take a long time to run, if your worried that the CLI froze, you can check the CloudFormation
panel in the AWS Console.**
    
This command creates a VPC for the Cerberus Environment including all needed networking resources: IAM Roles, S3 Buckets,
Bucket policies, and the RDS Instance needed for the Cerberus Management Service. See the
<a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/smaas-cf/smaas/vpc-and-base.py')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/smaas-cf/smaas/vpc-and-base.py">VPC and Base CloudFormation Troposphere</a>
and <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/java/com/nike/cerberus/operation/core/CreateBaseOperation.java')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/java/com/nike/cerberus/operation/core/CreateBaseOperation.java">Create Base Command Operation</a> for more information.

    
## Whitelist CIDRs and PORTS
You can use this command to white list corporate proxy boxes or even just your current IP.
You can run this command anytime you like and it will overwrite what the current values that exist on the security group
for VPC ingress. At a minimum you will need to whitelist your current ip for port 443, 8080, 8200, 8400, 22, while you
stand up the environment, because we need to talk directly to various instances during bootstrap and this can not be
done through the gateway.

Pro-tip for people who are not network ninjas and are unfamiliar with CIDR notation `0.0.0.0/0` is the entire internet,
`192.168.0.9/32` is the single ip4 address of `192.168.0.9`

Find your current public ip, or if your company uses a proxy take note of its IP/s.

For the demo environment I am going to whitelist my current public IP4 Address.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    whitelist-cidr-for-vpc-access \
    -cidr 50.39.106.150/32 \
    -port 443 -port 8080 -port 8200 -port 8500 -port 8400 -port 22

You can whitelist multiple CIDRs just like you can do with the ports `-cidr 192.168.0.2/32 -cidr 192.168.0.3/32`


## Upload Consul Certificate

Upload the Consul Certificate

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    upload-cert \
    --stack-name consul \
    --cert-path $CERBERUS_CERT_DIR

## Create Consul Config

Create the config needed for consul to run

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-consul-config


## Create Vault ACL for Consul

Create an ACL for Vault to have perms to use Consul

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-vault-acl


## Create Consul Cluster

Create the Consul Cluster, for this command we will need the following params

Parameter                      | Notes
-------------------------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `consul` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-consul-cluster \
    --instance-size t2.micro \
    --key-pair-name cerberus-demo \
    --costcenter no-op \
    --owner-email no-op@no-op.com \
    --owner-group no-op \
    --ami-id ami-80e04ce0

This command creates a Consul cluster (using the AMI we baked earlier), starts Consul and downloads the encrypted
configuration file that we generated. AWS Tags are then used to find other Consul clients in the same environment and
join their cluster, or to create a new Consul cluster if no other clients are found.

The Consul instances are configured to automatically backup there data to S3. Feel free to look through the 
<a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-consul-puppet-module')" href="https://github.com/Nike-Inc/cerberus-consul-puppet-module">Cerberus Consul Puppet Module</a> to learn more about how we configure
Consul.

## Upload Vault Certificate

Upload the Vault Certificate

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    upload-cert \
    --stack-name vault \
    --cert-path $CERBERUS_CERT_DIR


## Create Vault Config

Create the vault configuration that will enable TLS and have the consul config
    
    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-vault-config


## Create Vault Cluster

Parameter                      | Notes
-------------------------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `vault` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-vault-cluster \
    --instance-size t2.micro \
    --key-pair-name cerberus-demo \
    --costcenter no-op \
    --owner-email no-op@no-op.com \
    --owner-group no-op \
    --ami-id ami-fde34f9d

This will create an ASG of Vault instances that will automatically download our generated config and join the Consul
cluster in client mode. Once a Vault instance is initialized for an environment, it has the ability to unseal
itself by retrieving the encrypted data it needs from S3, calling KMS decrypt, and invoking the unseal endpoint on
itself.

Allowing Vault instances to unseal themselves makes the entire cluster resistant to failure because if one instance
becomes unhealthy or shuts down, then the ASG will spawn a new instance that can bootstrap itself. Feel free to look
through the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-vault-puppet-module')" href="https://github.com/Nike-Inc/cerberus-vault-puppet-module">Cerberus Vault Puppet Module</a> to learn more
about how we configure Vault.

## Initialize Vault
Next we need to initialize Vault which requires talking directly to the instances in the VPC, so if you need to use a
proxy you can do so by adding:

    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9000 \
    
after the region, but before the 'init-vault-cluster' command.

** **Note: You may need to wait a few minutes, after creating the Vault cluster, before you run this command.**
    
    cerberus --debug \
    -e demo \
    -r us-west-2 \
    init-vault-cluster

If you get an error message like the following:

    Exception in thread "main" com.nike.vault.client.VaultClientException: I/O error while communicating with vault.
    ...
    Caused by: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    
You probably need to add the CA for your cert provider to the Java trust store on the machine you are running the CLI.
Make sure the CA is in "DER" format.

<a href="#add-ca">See add the CA to your java trust store.</a>

Alternatively, a simple `ERROR: I/O error while communicating with vault` may be due to a proxy or firewall issue.

## Unseal Vault

Now we need to manually unseal vault for the first time. Instances will unseal themselves after future updates and
auto scaling events.

Unsealing the Vault instances requires talking directly to the instances in the VPC, so if you need to use a proxy you
can do so by adding:

    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9000 \

after the region, but before the 'unseal-vault-cluster' command.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    unseal-vault-cluster
    
Now, Vault should be ready to use. We can verify that everything's working by running the vault-health command like so,
again this command talks directly to the instances so include proxy information if needed:

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    vault-health
    
We expect to see 3 instances that are all "Sealed: false" and 1 instance that is "Standby: false," (this is the
elected leader).

## Load Default Policies in Vault

Lets load the default polices into Vault, this command talks directly to vault instances so provide proxy information
if needed.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    load-default-policies


## Upload CMS Certificate

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    upload-cert \
    --stack-name cms \
    --cert-path $CERBERUS_CERT_DIR


## Create CMS Vault Token

We need to create a token for CMS to use, CMS uses this token to create additional tokens for Users and AWS Resources
when they authenticate through CMS. This command needs proxy information if available.
    
    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-cms-vault-token


## Create CMS Config

Now we need to generate an encrypted properties file for CMS that contains the token as well as the auth connector
information. Supported auth connectors include OneLogin and Okta but it is easy to add others. 

The following parameters are required for all connectors

Parameter   | Notes
------------|------
admin-group | The group that admin users belong to, admin users have elevated privileges in the API.

You can add arbitrary params that will get written to the properties file by adding -P key=value

CMS requires the parameter `-P cms.auth.connector` with the fully qualified class name of the Auth connector 
implementation, e.g. `com.nike.cerberus.auth.connector.onelogin.OneLoginAuthConnector`

The OneLogin Auth Connector requires the following -P parameters:

Parameter                             | Notes
--------------------------------------|------
auth.connector.onelogin.api_region    | The OneLogin API region ex: us
auth.connector.onelogin.client_id     | The OneLogin API Client ID for this app, create one for Cerberus
auth.connector.onelogin.client_secret | The OneLogin API Client Secret for this app, create one for Cerberus
auth.connector.onelogin.subdomain     | The OneLogin API Subdomain ex: nike

For more information about auth connectors, including using Okta or writing your own custom auth connector, please 
see the <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-management-service/')" href="https://github.com/Nike-Inc/cerberus-management-service/">CMS</a> project.

For the demo environment I will run the command with the following:

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-cms-config \
    --admin-group Lst-digital.cpe.cerberus \
    -P cms.auth.connector=com.nike.cerberus.auth.connector.onelogin.OneLoginAuthConnector \
    -P auth.connector.onelogin.api_region=us \
    -P auth.connector.onelogin.client_id=$ONE_LOGIN_CLIENT_ID \
    -P auth.connector.onelogin.client_secret=$ONE_LOGIN_CLIENT_SECRET \
    -P auth.connector.onelogin.subdomain=nike


## Create CMS Cluster

Now that we have the config we need to stand up the CMS cluster using the AMI we built earlier.

Parameter                      | Notes
-------------------------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `cms` that you created earlier.
owner-group   | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email   | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter    | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-cms-cluster \
    --instance-size m3.medium \
    --key-pair-name cerberus-demo \
    --costcenter no-op \
    --owner-email no-op@no-op.com \
    --owner-group no-op \
    --ami-id ami-d1963ab1

## Publish Dashboard

Now we need to upload the Single Page App to S3

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    publish-dashboard \
    --artifact-url [https://github.com/Nike-Inc/cerberus-management-dashboard/releases]

## Upload Gateway Certificate

Upload the Certs for the Gateway ELB

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    upload-cert \
    --stack-name gateway \
    --cert-path $CERBERUS_CERT_DIR


## Create Gateway Config

Create the reverse proxy config for NGINX

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-gateway-config \
    --hostname demo.cerberus-oss.io

## Upload the Cloud Front Log Processing Lambda to S3

Upload the jar for the Lambda to S3

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    publish-lambda \
    --lambda-name WAF \
    --artifact-url https://github.com/Nike-Inc/cerberus-cloudfront-lambda/releases/download/v1.0.0/cerberus-cloudfront-lambda.jar

## Create Gateway Cluster

Now that we have all of the core Cerberus components, lets create the reverse proxy to route the unified API.

Parameter      | Notes
---------------|------
hosted-zone-id | This will be the Hosted Zone id of the Route 53 Hosted Zone that has your [PUBLIC DOMAIN] in my case it would be the hosted zone id for cerberus-oss.io.
instance-size  | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name  | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id         | The ami-id that for `gateway` that you created earlier.
owner-group    | Provide an owning group name. This value will be tagged on all resources possible to make it obvious what group owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
owner-email    | Provide a team or owner email. This value will be tagged on all resources possible to make it obvious the team or individual who owns the resources. (This is specific to how Nike tags resources and should be made optional in the future).
costcenter     | Provide a cost center name or other value (`no-op` would work).  This value will be tagged on all resources possible and is helpful for internal billing or other purposes. (This is specific to how Nike tags resources and should be made optional in the future).

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-gateway-cluster \
    --instance-size t2.micro \
    --key-pair-name cerberus-demo \
    --hosted-zone-id X5CT6JROG9F2DR \
    --hostname demo.cerberus-oss.io \
    --costcenter no-op \
    --owner-email no-op@no-op.com \
    --owner-group no-op \
    --ami-id ami-8144e9e1

**This command will take a long time to run, if your worried that the CLI froze, you can check the CloudFormation
panel in the AWS Console.**

## Create the Cloud Front Log Processing Lambda Config

Now that the Gateway stack has been created, we need to configure our Cloud Front Log Processing Lambda. Currently it
just handles rate limiting, so we need to define the limits and optionally configure it to message slack when CIDRs are
added or removed from the auto block ip set.

At this time there will be a Manual Whitelist and a Manual Blacklist IP Set that you can add or remove CIDRs to in the
AWS Dashboard. Just take a look at the resources that the gateway CloudFormation stack created to hunt these down.

The following parameters are Required

Parameter                                    | Notes
---------------------------------------------|------
rate-limit-per-minute                        | The number of requests per minute an IP can make before its added to the auto blacklist IP Set
rate-limit-violation-block-period-in-minutes | The number of minutes an IP will be blocked for violating the rate limit

If you would like to enable Slack integration and have the lambda message a slack channel when IPs are added or removed from the auto list you can configure the follwing params

Parameter                                    | Notes
-------------------|------
slack-web-hook-url | Your slack webhook url.
slack-icon         | A url to a custom icon, you can leave this off to use the default icon.


    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-cloud-front-log-processor-lambda-config \
    --rate-limit-per-minute 100 \
    --rate-limit-violation-block-period-in-minutes 60 \
    --slack-web-hook-url [slack webhook url] \
    --slack-icon [icon for slackbot]


## Upload the lambda to s3 for the CloudFront Security Group IP synchronizer

Now that we have our Origin ELB behind CloudFront and its configured to filter Manual Whitelist, Manual Blacklist, and
Auto Blacklist IPs and enforce other basic edge security, we don't want to allow requests to by pass the WAF and talk
to origin directly. Let's use Amazons Lambda for whitelisting only CloudFront IPs to the Origin ELB Security Group.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    publish-lambda \
    --artifact-url https://github.com/Nike-Inc/cerberus-lifecycle-cli/raw/master/update_security_groups.zip \
    --lambda-name CLOUD_FRONT_SG_GROUP_IP_SYNC

In the above command, `CLOUD_FRONT_SG_GROUP_IP_SYNC` is an enum name.

## Create the Lambda function and subscribe it to the AWS IP change topic

Now that we created a Lambda that can auto update the ingress of Security Groups on ELBs that are tagged appropriately,
lets subscribe to AWS topic that they publish to, when their IP space changes. So that we keep those Security
Groups up-to-date.

    cerberus -e demo -r us-west-2 create-cloud-front-security-group-updater-lambda