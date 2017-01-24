---
layout: post
title:  "Cerberus Java Client 1.2.0 Released"
date:   2017-01-04 12:00:00 -0700
categories: news
---

We started shading all of the dependencies of the Cerberus Java Client because AWS SDK version 
conflicts have been a frequent source of headaches for our customers.  

The main downside of this  change is this jar has grown to about 6MB in size.  The large jar
seems well worth it considering how frequently people have hit issues.  In the future, we
might look at more elegant solutions to this problem such as using REST for AWS calls or other 
packaging changes.

Please see the individual GitHub repos for the latest information on releases and current versions
(not all releases are mentioned in the news feed).
