---
layout: documentation
title: Roadmap
---

-  Add Okta support
-  Add additional commands to CLI for rotation of TLS Certificates and Vault tokens
-  Make Cerberus easier to use and deploy for other companies
   -  Pre-built AMIs, automation, improved documentation, work with early adopters
   -  Simplify environment creation by defining Cerberus environment in YAML and adding composite commands
   -  Automate TLS Certificate setup using Let's Encrypt (this would eliminate the most manual and error prone steps in creating an environment)
-  Finish open sourcing all components listed on the [components page](../components) that are not yet public
-  Treat files in a first class manner (files are supported via [API](../user-guide/file-storage) but support needs to be added to UI)
-  Improvements for SOX/PCI compliance such as auditing, change tracking
-  Increase horizontal scalability (consider replacing vault)

# Project History

-  **Jan 2016** - Active development of Cerberus began
-  **Sept 2016** - Cerberus internally used in production at Nike
-  **Nov 2016** - Initial open sourcing of Cerberus
