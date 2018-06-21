---
layout: documentation
title: Managing whitelist/blacklist
---

When an IP address makes more calls to Cerberus than the rate limit, the rate limiting Lambda adds the offending IP address to the **Auto Block Set** to blacklist this IP address, unless this IP already exists in either **Manual Block Set** or **White List Set**.

**White List Set**, **Manual Block Set**, and **Auto Block Set** are created as part of the **WAF** stack. You can add or delete IP addresses or ranges in the AWS console or via AWS CLI.
The priorities of the IP sets are **White List Set** > **Manual Block Set** > **Auto Block Set**.
When multiple Cerberus environments exist, you may need the IDs of the IP sets to find the correct one in **WAF**. The IDs of these sets can be found in **CloudFormation**.

## Limit Cerberus traffic to a corporate network

The rate limiting Lambda is only needed if your stack is on the **open internet**. You can ensure only traffic from corporate network is allowed by:
1. Blacklisting all IP addresses. Note that AWS WAF does not allow 0.0.0.0/0, so you'll have to use a workaround like for example [this code snippet for IPv4](https://gist.github.com/mayitbeegh/e60bac7694f54c7dd59405f0d32b247d)
1. Add only your IP addresses to the whitelist

## Check if an IP address is blocked by rate limiting Lambda

In the AWS console:
1. Navigate to **Services -> CloudFormation**
1. Find the **[environment name]-cerberus-web-app-firewall** stack in the list. Click on the stack name
1. Click **Outputs** to learn the IDs of the IP sets
1. Navigate to **Services -> WAF & Shield**
1. Click **Go to AWS WAF**
1. Click **IP addresses** in the sidebar
1. Make sure the correct region is selected in the filter
1. Click **Auto Block Set**

## Add IP address or range to whitelist/blacklist

1. Follow the above steps 1-7
1. Click **White List Set** or **Manual Block Set**
1. Click **Add IP addresses or ranges**
1. Enter the IP or range in CIDR notation
1. Click **Add IP address or range**
1. Click **Add**