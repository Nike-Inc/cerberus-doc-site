---
layout: documentation
title: Infrastructure Overview
---


<img src="../../images/infrastructure-overview/infrastructure-overview.png" />


# Edge Security

Cerberus uses the CloudFront WAF to provide edge security.  This is automatically setup with the 
[command-line API](../administration-guide/lifecycle-management-cli).

The WAF automatically drops requests with incorrect request body size, SQL injection, and Cross Site Scripting (XSS).

CloudFront access logs are parsed using a [rate limiting lambda](https://github.com/Nike-Inc/cerberus-cloudfront-lambda) 
that automatically blacklists IP addresses exceeding a configurable request rate limit.  The access logs are stored in 
S3 and every time a new log chunk is written to S3, the Lambda is triggered (every 10 minutes or so).

<img src="../../images/infrastructure-overview/edge-security.svg" />

For more background information, please see:

*  AWS white paper on [AWS Best Practices for DDoS Resiliency](https://d0.awsstatic.com/whitepapers/DDoS_White_Paper_June2015.pdf)
*  Blog post on [How to Configure Rate-Based Blacklisting with AWS WAF and AWS Lambda](https://blogs.aws.amazon.com/security/post/Tx1ZTM4DT0HRH0K/How-to-Configure-Rate-Based-Blacklisting-with-AWS-WAF-and-AWS-Lambda)

# Routing Requests

A Route 53 CNAME record points to the internet-facing Elastic Load Balancer (ELB) in the VPC. The ELB fronts an 
Auto Scaling Group (ASG) of [NGINX](https://www.nginx.com/) instances and handles reverse proxying of the 
[Cerberus Dashboard](../user-guide/dashboard), [Vault](vault), and the Cerberus Management Service. Only APIs from Vault that are 
required for managing secrets are exposed.

<img src="../../images/infrastructure-overview/routing-requests.png" style="width: 75%; height: 75%" />


# Vault and Consul

Consul is the underlying storage for [Vault](vault).

<img src="../../images/infrastructure-overview/vault-and-consul.png" style="width: 75%; height: 75%"/>


# Cerberus Management Service

The Cerberus Management Service is a microservice that was created to add needed features without modifying the 
Vault project including:

*  Management of Safe Deposit Boxes
*  User Authentication
*  AWS IAM Role Authentication
*  Permissions Management

<img src="../../images/infrastructure-overview/cerberus-management-service.png" style="width: 75%; height: 75%;" />


# References

*  [AWS CloudFront](https://aws.amazon.com/cloudfront/)
*  [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/)
*  [AWS Route 53](https://aws.amazon.com/route53/)
*  [AWS Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/)
*  [AWS Elastic Load Balancing (ELB)](https://aws.amazon.com/elasticloadbalancing/)
*  [AWS Auto Scaling](https://aws.amazon.com/autoscaling/)
*  [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/)
*  [NGINX](https://www.nginx.com/)