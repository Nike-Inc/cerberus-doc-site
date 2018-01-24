---
layout: documentation
title: Quick Start
---

This is a quick start guide for application developers who want to use the Cerberus service.  This guide assumes a 
Cerberus environment has been setup as described in the [Administration guide](../administration-guide/creating-an-environment).

Cerberus is a complete solution to manage anything that you want to tightly control access to, such as API keys, 
passwords, certificates, etc. By the end of this document you will be able to provision a safe deposit box (SDB), set the 
correct permissions, and integrate a cerberus client library to access data from your application.  A safe 
deposit box (SDB) is a logical grouping of data with a single set of access controls.

# 1. Configure your Service's IAM Role

The EC2 instance must be assigned an IAM role that has been given permissions to at least one safe deposit box (SDB) in Cerberus.
The IAM role to be assigned must contain, at a minimum, a IAM policy statement giving access to call the KMS' decrypt action.

1. Login to the AWS console
1. Navigate to the Identity and Access Management section
1. Configure a role with the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowKmsDecrypt",
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

The account ID in the ARN should be the account ID where Cerberus is deployed.  See your company's internal
documentation for the account ID that you should use.

# 2. Create a Safe Deposit Box

1. Login to the Cerberus [dashboard](dashboard) with your credentials.
1. In the left navigation bar, click the '+' button next to the Applications section.
1. Enter a friendly name for your SDB.  If your app is 'myawesomeapp', go with 'My Awesome App'.
1. The owner field is the LDAP group that will have ownership for this SDB.  You can select one of the LDAP groups you 
   are currently a member of.
1. Under 'User Group Permissions' you can give additional LDAP groups you are a member of read or write access to the SDB.
1. Under 'IAM Role Permissions' you provide the AWS account id and role name that will have either read or write access 
   to the SDB.
1. Click the 'SUBMIT' button

<a href="../../images/dashboard/create-new-safe-deposit-box-screen.png" target="_blank">
<img src="../../images/dashboard/create-new-safe-deposit-box-screen.png" alt="Cerberus Dashboard new SDB screenshot" style="width: 25%; height: 25%;"/>
</a>

# 3. Manage Data in your Safe Deposit Box

Data is stored using a path structure.  Note that the application name is normalized to be 
URL friendly.  So, if you had 'My Awesome App' in the Applications category your root path will be 
'applications/my-awesome-app'.  From there you can add sub-paths to store key value pairs.

Cerberus will allow an SDB to contain a folder structure with many subpaths but for most applications a single path with
a list of several key/value pairs is optimal (that way all values can be read later with a single API call).

### How to add a subpath:
1. Click the 'Add new path' button.
1. Enter a subpath name
1. Add the key/value pairs that you'd like to store at that subpath.
1. Click 'SAVE'
1. The page will refresh and you'll be able to add more subpaths or edit the subpath you just added.

<a href="../../images/dashboard/add-new-path-screen.png" target="_blank">
<img src="../../images/dashboard/add-new-path-screen.png" alt="Cerberus Dashboard add new path screenshot" style="width: 25%; height: 25%;"/>
</a>

# 4. Access Your Secrets with Cerberus

Use one of the clients:

* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-java-client')" href="https://github.com/Nike-Inc/cerberus-java-client">Java Client</a>
* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-archaius-client')" href="https://github.com/Nike-Inc/cerberus-archaius-client">Java Archaius Polling Client</a> (generally preferred for 
  companies using [Archaius](archaius))
* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-java-client')" href="https://github.com/Nike-Inc/cerberus-node-client">Node Client</a>
* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-python-client')" href="https://github.com/Nike-Inc/cerberus-python-client">Python Client</a>
* <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-ruby-client')" href="https://github.com/Nike-Inc/cerberus-ruby-client">Ruby Client</a>

Don't see your desired client? Cerberus has a REST API. You 
can [contribute](../contributing/how-to-contribute) a new client or use the [REST API](../architecture/rest-api) directly.

# Local Development

## Getting a Cerberus Token

To make use of Cerberus locally you'll need a token to access secrets from your application.
Most of the clients allow setting of a environmental or system property to enable local development with a user token.

The easiest way to get a token is to login to the [dashboard](dashboard) and view your token under the upper right hand menu.

Alternatively, download <a target="_blank" onclick="trackOutboundLink('https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh')" href="https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh">cerberus-token.sh</a> to 
your dev machine and use it to retrieve a token for development work.  This shell script requires <a target="_blank" onclick="trackOutboundLink('https://stedolan.github.io/jq/')" href="https://stedolan.github.io/jq/">jq</a> available in your path

Use the --help option for usage:

```bash
./cerberus-token.sh --help
```

## Verifying Your Identity

A common problem encountered during setup is a different role is in effect than expected by the developer.

See [Who am I?](troubleshooting) for more information.
