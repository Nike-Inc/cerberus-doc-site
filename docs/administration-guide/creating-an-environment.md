---
layout: documentation
title: Creating a Cerberus Environment
---

## Bake the necessary Cerberus AMIs
Clone or download the [Cerberus Utility Script](https://github.com/Nike-Inc/cerberus-util-scripts) project and follow the README to create AMIs for Consul, Vault, Gateway and Cerberus Management Service

## Configure the Lifecycle Management CLI
Ensure that you have the [Cerberus Lifecycle CLI](https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases/latest) available on your command line and that you have a Java 8 JRE, with Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy.

For this guide I will assume you have the following in your bash profile `alias cerberus='java -jar /path/to/cerberus.jar'`, if you do not, replace `cerberus` with `java -jar /path/to/jar`

Install the AWS CLI, it is not technically needed to stand up the environment, but it is needed to delete an environment and a good tool to have.
Configure your AWS credentials for your machine. `aws configure` **If you do not do this you will need to make sure you provide credentials as documented in the link below** 

See [Working with AWS Credentials](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html) for all the ways you can supply credentials to the Cerberus Lifecycle CLI. We use the default credential provider chain with the exception that we have added an STSAssumeRoleSessionCredentialsProvider, for build systems to be able to assume a role. You can hook into this by using `CERBERUS_ASSUME_ROLE_ARN` and `CERBERUS_ASSUME_ROLE_EXTERNAL_ID` environmental variables.

## Configure a hosted zone for your AWS account.

Ensure that you have a Hosted Zone configured in AWS.

## Create a certificate for the Cerberus Environment

Ensure that you have have created a certificate with the following Subject Name and Subject Alternative Names
If your company does not have a way for getting certs, checkout [Lets Encrypt](https://letsencrypt.org/), a free, automated, and open Certificate Authority. As of right now, self signed certs will not work with our automation as we have no hooks for injecting custom CAs, or disabling SSL verification.

    [ENVIRONMENT NAME].[PUBLIC DOMAIN]
    origin.[ENVIRONMENT NAME].[PUBLIC DOMAIN]
    vault.[REGION].[ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]
    consul.[REGION].[ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]
    cms.[REGION].ENVIRONMENT NAME].[VPC INTERNAL HOSTED ZONE NAME]
    
We will need to ensure that we have the following files in a directory that the CLI will reference

file       | purpose
---------- | ---------------------------------
pubkey.pem | the public key
key.pem    | the private key
ca.pem     | the certificate authority key
cert.pem   | the cert
  
Venafi will let you download a cert as an open ssl pem.
If you have a single pem you would need to open in it up in an editor
copy the cert section at the top to cert.pem and copy the ca section to ca.pem
and run the following commands to extract the private and public keys

    openssl rsa -in privkey.pem -pubout > pubkey.pem  
    openssl rsa -in privkey.pem -out key.pem
    
For my OSS Demo environment I will use [Lets Encrypt](https://letsencrypt.org/) to create a cert for

    demo.cerberus-oss.io
    origin.demo.cerberus-oss.io
    vault.us-west-2.demo.internal.cerberus-oss.io
    consul.us-west-2.demo.internal.cerberus-oss.io
    cms.us-west-2.demo.internal.cerberus-oss.io
    
Here is a breakdown of what each entry will be used for.

```
demo.cerberus-oss.io
origin.demo.cerberus-oss.io
```
Will be in a public hosted zone in route 53, the top level record will point to CloudFront which will be the entry point for Users of the environment.

The origin record will point to the public facing ELB for the Gateway stack, but it will get a Security Group that only allows access to CloudFront IPs.

```
vault.us-west-2.demo.internal.cerberus-oss.io 
consul.us-west-2.demo.internal.cerberus-oss.io 
cms.us-west-2.demo.internal.cerberus-oss.io
``` 
will be in a private hosted zone and used by the ELBs for the various ASGs in the VPC.
    
To do this I used the cert-bot and created A records to the above CNAMES to point to a machine that had NGINX on it and ran the cert-bot wizard.

at the end I had the following files in `/etc/letsencrypt/live/demo.cerberus-oss.io`

    cert.pem  chain.pem  fullchain.pem  privkey.pem
    
I copied them to my laptop and ran the following commands

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

**Let's Encrypt is not trusted by Java by default, we need to add it to our local trust store, I followed the directions outlined [here in this stack overflow answer](http://stackoverflow.com/a/37969672/770134)**

## Generate a SSH Key Pair for your Cerberus instances using the AWS Console

Go to the EC2 panel and navigate to Key Pairs and generate a new key pair or pairs to use for the Cerberus environment.
For the demo I will use one key-pair for all the Cerberus component instances, but you can have a different key pair for each core component if you wish.

## Create the VPC for the Cerberus Environment and set up the base resources needed for the environment
You will need to supply the following parameters

Parameter                      | Notes
-------------------------------|------
admin-role-arn                 | an ARN for an IAM Role that will be given permission to administrate the KMS keys created by the CLI. If you have SSO integrated into AWS IAM and there is a role that admins get use that role, or else just create a new role for this.
vpc-hosted-zone-name           | This is the private hosted zone that ELBs in the Cerberus env VPC will use. in our demo case we would use `demo.internal.cerberus-oss.io`
owner-email                    | This is specific to the way we tag resources, we haven't made this optional yet, use an email that is for you team or your email. This value will be tagged on all resources possible.
costcenter                     | This is specific to the way we tag resources, we haven't made this optional yet, you can put what ever you would like here, `no-op` would work
        
Here is the command to run with our demo values, make sure to replace the values with your own.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-base \
    --admin-role-arn [ADMIN ARN] \
    --vpc-hosted-zone-name demo.internal.cerberus-oss.io \
    --owner-email no-op@no-op.com \
    --costcenter no-op
    
**This command will take a long time to run, if your worried that the CLI froze, you can check the CloudFormation panel in the AWS Console.**
    
This command does a lot of heavy lifting it creates a VPC for the Cerberus Environment bootstrapping all the needed networking resources, IAM roles, S3 buckets, bucket policies, and the RDS instance needed for the Cerberus Management Service. See the [VPC and Base CloudFormation Troposphere](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/smaas-cf/smaas/vpc-and-base.py) and [Create Base Command Operation](https://github.com/Nike-Inc/cerberus-lifecycle-cli/blob/master/src/main/java/com/nike/cerberus/operation/core/CreateBaseOperation.java) for more information.

    
## Whitelist CIDRs and PORTS
You can use this command to white list corporate proxy boxes or even just your current IP.
You can run this command anytime you like and it will overwrite what the current values that exist on the security group for VPC ingress.
At a minimum you will need to whitelist your current ip for port 443, 8080, 8200, 8400, 22, while you stand up the environment, because we need to talk directly to various instances during bootstrap and this can not be done through the gateway.

Pro-tip for people who are not network ninjas and are unfamiliar with CIDR notation `0.0.0.0/0` is the entire internet, `192.168.0.9/32` is the single ip4 address of `192.168.0.9`

Find your current public ip, or if your company uses a proxy take note of its IP/s.

For the demo environment I am going to whitelist my current public IP4 Address.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    whitelist-cidr-for-vpc-access \
    -cidr 50.39.106.150/32 \
    -port 443 -port 8080 -port 8200 -port 8500 -port 8400 -port 22

You can whitelist multiple CIDRs just like you can do with the ports `-cidr 192.168.0.2/32 -cidr 192.168.0.3/32`



## Upload the Consul Certificate

Upload the certs for consul to IAM

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
owner-group   | This is specific to the way we tag resources, we haven't made this optional yet, what ever value you want. This value will be tagged on all resources possible.
owner-email   | This is specific to the way we tag resources, we haven't made this optional yet, use an email that is for you team or your email. This value will be tagged on all resources possible.
costcenter    | This is specific to the way we tag resources, we haven't made this optional yet, you can put what ever you would like here, `no-op` would work


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

This command creates a consul cluster that uses the AMI we baked earlier that will start consul and download our generated encrypted config and use AWS Tags to auto discovery each other by environment and create / join a cluster. The Consul instances are configured to automatically backup there data to S3. Feel free to dig through the [Cerberus Consul Puppet Module](https://github.com/Nike-Inc/cerberus-consul-puppet-module) to learn more about how we configured all this. 

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
owner-group   | This is specific to the way we tag resources, we haven't made this optional yet, what ever value you want. This value will be tagged on all resources possible.
owner-email   | This is specific to the way we tag resources, we haven't made this optional yet, use an email that is for you team or your email. This value will be tagged on all resources possible.
costcenter    | This is specific to the way we tag resources, we haven't made this optional yet, you can put what ever you would like here, `no-op` would work

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

This will create an ASG of Vault instances that will auto download config and join the Consul cluster in client mode.
once Vault is initialized for an environment they will have the ability to unseal themselves by grabbing the encrypted data they need from S3 and using KMS to decrypt and calling the unseal endpoint on themselves.
This makes the the cluster resistant to failure because if an instance becomes unhealthy or shutdown, the ASG will spawn a new instance that will automatically bootstrap itself. Feel free to dig through the [Cerberus Vault Puppet Module](https://github.com/Nike-Inc/cerberus-vault-puppet-module) to learn more about how we configured all this.

## Initialize Vault
You may need to wait a few minutes before running this command right after making the cluster.
Now we need to initialize Vault which requires taking directly to the instances in the VPC, so if you need to use a proxy you can do so by adding

    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9000 \
    
after the region, but since for this environment, I whitelisted my IP I can talk directly to the instances without a proxy.
    
    cerberus --debug \
    -e demo \
    -r us-west-2 \
    init-vault-cluster

If you get an error message like the following 

    Exception in thread "main" com.nike.vault.client.VaultClientException: I/O error while communicating with vault.
    ...
    Caused by: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    
You probably need to add the CA for your cert provider to the Java trust store on the machine you are running the CLI.

## Unseal Vault

Now we need to manually unseal vault for the first time, future updates and auto scaling events instances will unseal themselves

This requires taking directly to the instances in the VPC, so if you need to use a proxy you can do so by adding

    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9000 \

after the region, but since for this environment, I whitelisted my IP I can talk directly to the instances without a proxy.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    unseal-vault-cluster
    
Now vault should be ready to be used, we can verify things have worked as expected by running the vault-health command like so, again this command talks directly to the instances so include proxy information if needed.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    vault-health
    
We expect to see 3 instances that are all Sealed: false and 1 instance that is Standby: false, this is the elected leader.

## Load Default Policies in Vault

Lets load the default polices into Vault, this command talks directly to vault instances so provide proxy information if needed.

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

We need to create a token for CMS to use, CMS uses this token to create tokens for Users and AWS Resources when they auth through CMS, this command needs proxy information if available.
    
    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-cms-vault-token


## Create CMS Config

Now we need to generate an encrypted props file for CMS that contains the token as well as auth connector information.
Currently the only supported auth connector is OneLogin, see the README for CMS to learn more about implementing your own auth connector, we plan on creating one for OKTA very soon.

The following parameters are required for all connectors

Parameter   | Notes
------------|------
admin-group | The group that admin users belong to, admin users have elevated privileges in the API.

You can add arbitrary params that will get written to the properties file by adding -P key=value

CMS requires the following -P parameters

`cms.auth.connector`, The fully qualified classname of the Auth connector implementation, currently we only have OneLogin: com.nike.cerberus.auth.connector.onelogin.OneLoginAuthConnector

OneLogin Auth Connector requires the following -P parameters

Parameter                             | Notes
--------------------------------------|------
auth.connector.onelogin.api_region    | The OneLogin API region ex: us
auth.connector.onelogin.client_id     | The OneLogin API Client ID for this app, create one for Cerberus
auth.connector.onelogin.client_secret | The OneLogin API Client Secret for this app, create one for Cerberus
auth.connector.onelogin.subdomain     | The OneLogin API Subdomain ex: nike

**A note about our OneLogin Connector Impl**
We get user groups from the member-of field, which is wired to our LDAP groups, if you don't do this do our OneLogin connector in its current form will not work for you.

For the demo environment I will run the command with the following

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

Now that we have the config we need we can stand up the CMS cluster using the AMI we built easier

Parameter                      | Notes
-------------------------------|------
instance-size | The instance size you would like to use for Consul, for the demo I am going to use micros, you can always use the update command to change the size later.
key-pair-name | The name of the ssh key pair you created easier for us we created one called `cerberus-demo`
ami-id        | The ami-id that for `cms` that you created earlier.
owner-group   | This is specific to the way we tag resources, we haven't made this optional yet, what ever value you want. This value will be tagged on all resources possible.
owner-email   | This is specific to the way we tag resources, we haven't made this optional yet, use an email that is for you team or your email. This value will be tagged on all resources possible.
costcenter    | This is specific to the way we tag resources, we haven't made this optional yet, you can put what ever you would like here, `no-op` would work

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
owner-group    | This is specific to the way we tag resources, we haven't made this optional yet, what ever value you want. This value will be tagged on all resources possible. 
owner-email    | This is specific to the way we tag resources, we haven't made this optional yet, use an email that is for you team or your email. This value will be tagged on all resources possible.
costcenter     | This is specific to the way we tag resources, we haven't made this optional yet, you can put what ever you would like here, `no-op` would work

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    create-gateway-cluster \
    --instance-size t2.micro \
    --key-pair-name cerberus-demo \
    --hosted-zone-id ZKW2RA5PJIHDH \
    --hostname demo.cerberus-oss.io \
    --costcenter no-op \
    --owner-email no-op@no-op.com \
    --owner-group no-op \
    --ami-id ami-8144e9e1

**NOTE: This command takes a long time**

## Create the Cloud Front Log Processing Lambda Config

Now that the Gateway stack has been created, we need to configure our Cloud Front Log Processing Lambda. Currently it just handles rate limiting, so we need to define the limits and optionally configure it to message slack when CIDRs are added or removed from the auto block ip set.

At this time there will be a Manual Whitelist and a Manual Blacklist IP Set that you can add or remove CIDRs to in the AWS Dashboard. Just take a look at the resources that the gateway CloudFormation stack created to hunt these down.

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
    -e dmeo \
    -r us-west-2 \
    create-cloud-front-log-processor-lambda-config \
    --rate-limit-per-minute 100 \
    --rate-limit-violation-block-period-in-minutes 60 \
    --slack-web-hook-url [slack webhook url] \
    --slack-icon [icon for slackbot]


## Upload the lambda to s3 for the CloudFront Security Group IP synchronizer

Now that we have our Origin ELB behind CloudFront and its configured to filter Manual Whitelist, Manual Blacklist, and Auto Blacklist IPs and enforce other basic edge security, we don't want to allow requests to by pass the WAF and talk to origin directly. Let's use Amazons Lambda for whitelisting only CloudFront IPs to the Origin ELB Security Group.

    cerberus --debug \
    -e demo \
    -r us-west-2 \
    publish-lambda \
    --artifact-url https://github.com/Nike-Inc/cerberus-lifecycle-cli/raw/master/update_security_groups.zip \
    --lambda-name CLOUD_FRONT_SG_GROUP_IP_SYNC


## Create the Lambda function and subscribe the ip topic

Now that we created a Lambda that can auto update the ingress of Security Groups on ELBs that are tagged appropriately, lets subscribe to AWS topic that they publish to, when ever their IP space changes. So that we keep those Security Groups up to date.

    cerberus -e demo -r us-west-2 create-cloud-front-security-group-updater-lambda