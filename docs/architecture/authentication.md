---
layout: documentation
title: Authentication
---

Cerberus currently supports authenticating EC2 instances, AWS Lambdas, and Users.

# EC2 Instance Authentication

One of the key components of the Cerberus offering is a simple yet secure solution for accessing privileged data from 
an EC2 instance.  Within Cerberus, the logical grouping of related data is referred to as a safe deposit box (SDB). This
SDB in a collection of metadata describing the data and a set of permissions for what LDAP groups and AWS IAM roles 
have access.

## Assumptions

If more than one IAM role is associated with the EC2 instance, the first one to authenticate successfully with Cerberus will be used.

## Prerequisites

The EC2 instance must be assigned an IAM role that has been given permissions to at least one SDB in Cerberus.
The IAM role to be assigned must contain, at a minimum, a IAM policy statement giving access to call the KMS' decrypt
action:

```json
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
```

The account ID in the ARN should be the account ID where Cerberus is deployed.

## Sequence

The Cerberus Java client provides a credentials provider that is able to authenticate with Cerberus based on the 
assigned IAM roles to that instance.

1. Lookup the AWS account ID from EC2 metadata service
1. Lookup all the IAM roles assigned to the instance from EC2 metadata service
1. For each assigned IAM role:
   1. Request encrypted auth response from Cerberus
   1. Attempt to decrypt response with KMS
1. Store the auth token and expire time

<img src="../../images/arch-diagrams/cms-iam-auth-sequence-diagram.png" alt="IAM authentication sequence diagram" />

# Lambda Authentication

Lambda authentication is similar to that of EC2 instances.  See the 
<a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda')" href="https://github.com/Nike-Inc/cerberus-serverless-components/tree/master/cerberus-health-check-lambda">health check lambda</a> for a complete example.

# User Authentication

Cerberus supports plugging in different authentication backends.  The example below shows 
<a target="_blank" onclick="trackOutboundLink('https://www.onelogin.com/')" href="https://www.onelogin.com/">OneLogin</a> but <a target="_blank" onclick="trackOutboundLink('https://www.okta.com/')" href="https://www.okta.com/">Okta</a> is also supported and
others can be added easily.  LDAP groups are used to provide role-based access with either read or read/write
permissions.

<img src="../../images/arch-diagrams/user-authentication.png" alt="User authentication diagram" style="width: 50%; height: 50%; margin: 50px;" />


# References

*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/ec2/')" href="https://aws.amazon.com/ec2/">Amazon EC2 - Virtual Server Hosting</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/iam/')" href="https://aws.amazon.com/iam/">AWS Identity and Access Management (IAM)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/kms/')" href="https://aws.amazon.com/kms/">AWS Key Management Service (KMS)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://www.onelogin.com/')" href="https://www.onelogin.com/">OneLogin</a>
*  <a target="_blank" onclick="trackOutboundLink('https://www.okta.com/')" href="https://www.okta.com/">Okta</a>
