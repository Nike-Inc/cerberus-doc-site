---
layout: documentation
title: Lambdas
---

Generally it does NOT make sense to store Lambda secrets in Cerberus for two reasons:
   
1. Cerberus cannot support the scale that lambdas may need, e.g. thousands of requests per second
1. Lambdas will not want the extra latency needed to authenticate and read from Cerberus
   
A better solution for Lambda secrets is using the [encrypted environmental variables](http://docs.aws.amazon.com/lambda/latest/dg/env_variables.html) 
feature provided by AWS.
   
Another option is to store Lambda secrets in Cerberus but only read them at Lambda deploy time, then storing them as encrypted 
environmental variables, to avoid the extra Cerberus runtime latency.