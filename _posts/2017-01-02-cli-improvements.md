---
layout: post
title:  "Lifecycle Management CLI Improvements"
date:   2017-01-02 12:00:00 -0700
categories: news
---

Cerberus includes a Command Line Interface (CLI) for managing Cerberus environments. In the past few 
weeks we've <a target="_blank" onclick="trackOutboundLink('https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases')" href="https://github.com/Nike-Inc/cerberus-lifecycle-cli/releases">released several new versions</a>. 

New CLI features include:

- Optional Google Analytics on CloudFront Logs
- Better `--help` with easier to read usage information
- Added a `--version` option plus a wrapper script that prompts and optionally downloads latest version of the CLI
- Updated generate Vault config command to be re-runnable
- Made Vault Token TTL configurable
- Added "fail early validation" to ensure Unlimited Strength Encryption is installed in the JRE
- Added option for customization of help inside Cerberus dashboard

Please see the individual GitHub repos for the latest information on releases and current versions.