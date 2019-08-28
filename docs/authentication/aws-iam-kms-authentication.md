---
layout: documentation
title: AWS IAM KMS Authentication
---

This is Cerberus's original AWS IAM authentication mechanism, we consider this to be deprecated and are actively perusing ways of removing / disabling the endpoint in the near future. 

# IAM Authentication

One of the key components of the Cerberus offering is a simple yet secure solution for accessing privileged data from 
an EC2 instance. Within Cerberus, the logical grouping of related data is referred to as a safe deposit box (SDB). This
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

<a name="regions"></a>
# A note about regions

The various Cerberus clients take in as an argument a region, when using KMS auth, the supplied region is the AWS region that Cerberus will create a KMS key for you in, and the region that you will have to use KMS decrypt in to get your payload.
You will want to make this the region you are running in and not hard code this region. So that if there is an KMS outage in 1 region your services in another region will continue to work.

# References

*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/ec2/')" href="https://aws.amazon.com/ec2/">Amazon EC2 - Virtual Server Hosting</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/iam/')" href="https://aws.amazon.com/iam/">AWS Identity and Access Management (IAM)</a>
*  <a target="_blank" onclick="trackOutboundLink('https://aws.amazon.com/kms/')" href="https://aws.amazon.com/kms/">AWS Key Management Service (KMS)</a>