---
layout: documentation
title: AWS STS Authentication
---

This is the newest and preferred method for authenticating with Cerberus as an AWS IAM principal.

<a name="how"></a>
# How it works

the AWS STS API has an endpoint called [Get Caller Identity](http://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html) this endpoint was released after the initial release of Cerberus and the now deprecated [AWS IAM KMS auth flow](aws-iam-kms-authentication).

When you make a request to the STS get-caller-identity API via using the V4 AWS Signing process with your IAM credentials you get a response with the identity of the active AWS IAM credentials like the following.

```json
{
  "UserId": "AROAIJXNEPZUXXXYYYSS:justin.field@example.com",
  "Account": "1111111111111",
  "Arn": "arn:aws:sts::1111111111111:assumed-role/OktaAWSAdminRole/justin.field@example.com"
}
```

Basically our [clients](/cerberus/components/) use your AWS IAM Credentials via the various AWS SDKs to [V4 Sign](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html) a [Get Caller Identity](http://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html) request. 
We then pass signed request parts to Cerberus so that it can finish the get caller identity request on your behalf and parse the ARN from the response and authenticate you as the returned principal.

<a name="why"></a>
# Why it's better than the AWS KMS Authentication flow

With the [AWS IAM KMS auth flow](aws-iam-kms-authentication) we had to create a KMS CMK per IAM role per region when they authenticated for the first time. While we cleaned up unused keys every 30 days configurable, we still end up with a lot of Keys and they add up to real money.

Costs aside every time a principal authenticated using this method we would have to make an API call to KMS to encrypt a token, KMS has [RPS API Limits](https://docs.aws.amazon.com/kms/latest/developerguide/limits.html#requests-per-second-table). Since we also use KMS for our data this can contribute to scaling limitations.

Another issue with KMS was that you need a special IAM policy in order to authenticate with Cerberus using KMS. 
You have to allow any IAM principal permissions to decrypt any KMS key coming from the Cerberus account. 
This provides developer on boarding friction and a support burden for Cerberus Operators. 
This also limits the ability for Cerberus operators to move accounts easily.

Finally with KMS auth operators of Cerberus basically have to run Cerberus in it's own account because anyone in the same account can externally create manipulate AWS ACLs and impersonate IAM Principals and gain access to data that they should not have access to. We plan on disabling KMS auth by default soon to eliminate this concern. 

<a name="paths"></a>
# A note about IAM paths and STS vs KMS IAM auth

IAM allows you to add something called a [path](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#identifiers-friendly-names), when you use the API directly to create an IAM role.

When you make a call to STS get caller identity, the response does not contain the path, therefore AWS IAM STS auth for Cerberus does not support paths.

What this means is that when you are granting permissions to an IAM principal you must omit the path from the ARN when setting up permissions for you SDB.

EX: With KMS auth you might have had a permissions that was like so: 

```
arn:aws:iam::1111111111111:role/some/path/ZookeepersAdminRole
```

With STS auth this must be updated to 

```
arn:aws:iam::1111111111111:role/ZookeepersAdminRole
``` 

This is due to the STS returning an arn like the following. 

```
arn:aws:sts::1111111111111:assumed-role/ZookeepersAdminRole/justin.field@example.com
```

The above arn would match against the following arn configured for an SDB.

```
# This is the base role, so all sessions (instances or people) with access to this role.
arn:aws:iam::1111111111111:role/ZookeepersAdminRole
# This would just grant access to justin.field@example.com only.
arn:aws:sts::1111111111111:assumed-role/ZookeepersAdminRole/justin.field@example.com/
```

However it will not match against the following.    

```
arn:aws:iam::1111111111111:role/some/path/ZookeepersAdminRole
```

So as a Cerberus consumer, when you update your clients since we are removing KMS auth from all clients, you will need to update permissions in your SDBs if you are currently utilizing IAM paths.

<a name="local"></a>
# A better pattern for local development

A good benefit of using STS auth with a tool such as [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds) is that you can enable a better local development experience.

In the past we would recommend using a script or the dashboard to fetch an auth token and set it to an env var `CERBERUS_TOKEN=xxxxx` and our clients would pick that up and use it.

With STS auth, you can locally develop the same way as your code will work deployed. Just use [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds) to get creds for a role and add that role to your SDB.

For example let's say I am on the zookeepers team, and we have an IAM role that we use and I can get credentials for it like follows:

```bash
AP77JGH6A84FA3:~ jfiel2$ gimme-aws-creds --profile zookeepers
Using password from keyring for justin.field@example.com
Multi-factor Authentication required.
token:software:totp( GOOGLE ) : justin.field@example.com selected
Enter verification code: 111111
writing role arn:aws:iam::1111111111111:role/ZookeepersAdminRole to /home/jfiel2/.aws/credentials
AP77JGH6A84FA3:~ jfiel2$ aws sts get-caller-identity
{
    "UserId": "AROAIJXNEPZUXXXYYYSS:justin.field@example.com",
    "Account": "1111111111111",
    "Arn": "arn:aws:sts::1111111111111:assumed-role/ZookeepersAdminRole/justin.field@example.com"
}
```

With the above example I can either add the STS ARN for the specific user:

`arn:aws:sts::1111111111111:assumed-role/ZookeepersAdminRole/justin.field@example.com`

Or the base role ARN: 

`arn:aws:iam::1111111111111:role/ZookeepersAdminRole` 

Effectively adding a specific user, or all users that are able to assume that role.

<a name="regions"></a>
# A note about regions

The various Cerberus clients take in as an argument a region, when using STS auth, the supplied region is the AWS region that you are v4 signing the sts get caller identity request with and the region that Cerberus will attempt to use STS on your behalf in.
You will want to make this the region you are running in and not hard code this region. So that if there is an STS outage in 1 region your services in another region will continue to work.
