---
layout: post
title: Security - Updated Deployment Guidelines
date: 2017-02-20 12:00:00 -0700
categories: news
---

Two required updates for Cerberus security: 1) new IAM role policy, and 2) run Cerberus in its own account.

1) New IAM role policy

{% highlight json %}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow KMS Decrypt",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:*:[Cerberus AWS Account ID]:key/*"
            ]
        }
    ]
}
{% endhighlight %}

The account ID in the ARN should be the account ID where Cerberus is deployed.

Learn more in the [Quick Start Guide](/cerberus/docs/user-guide/quick-start) and in the documentation describing
[authentication](/cerberus/docs/architecture/authentication).

2) Run Cerberus in its own account

Due to how Cerberus uses KMS as part of its [authentication](/cerberus/docs/architecture/authentication) we strongly
recommended running Cerberus in its own account for security reasons.  Running Cerberus in its own account prevents 
services from being able to impersonate each other.  For example, since KMS keys are created on demand per ARN the IAM
role policy is not specific to a single key.

We've discussed this problem with contacts at AWS and there is a limited work around using a NotPrincipal but it turns
out this not work with assumed roles, a common use case.  The simplest solution is to run Cerberus in its own account.
In the future, we hope to remove this limitation by changing how we do authentication.

All relevant documentation has been updated to reflect the above two points.