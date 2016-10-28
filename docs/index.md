---
layout: documentation
title: What Is Cerberus
---

<div class="documentation-landing-header-container">
    <div class="documentation-landing-header">
        <div class="docu-image" >
            <img src="/cerberus/images/cerberus-github-logo-black-filled-circle@300px.png">    
        </div>
        <div class="docu-text u-uppercase">
            <div><h1>Cerberus</h1></div>
            <div><h2>A Secure Dynamic Property Solution for AWS</h2></div>
        </div>
    </div>
</div>

## 1. [What is Cerberus?](#what-is-cerberus)

## 2. [What is Cerberus for?](#what-is-cerberus-for)

## 3. [What Problem Does Cerberus Solve?](#what-problem-does-cerberus-solve)

<a name="what-is-cerberus"></a>

# [What is Cerberus?](#what-is-cerberus)

Cerberus is a hosted solution that allows teams to increase business agility and decrease risk by securely managing secrets like passwords and API keys as well as non-sensitive dynamic run-time properties like feature flags or logging levels.

Manage your properties and access control using the self-service web UI.

Have your cloud applications (running on AWS EC2 or Lambda in any AWS account) retrieve properties at run time using one of [several client libraries](/cerberus/components/#clients).

Behind the scenes Cerberus is an API that composes a few services.

-   Dashboard
    -   We provide a single page app that users can use to create SDBs and manage their secrets
-   Vault
    -   Cerberus uses HashiCorp's Vault to manage the actual encryption at rest and access control to of the secrets.
-   Cerberus Management Service
    -   Vault was missing a few key features around cloud instance and OneLogin authentication and authorization, so we created a microservice and composed the vault api to create the concept of a SDB.

Once a team has and SDB setup with secrets they can use one of our several clients to access their secrets in their apps, please see the User Guide for more information.

<a name="what-is-cerberus-for"></a>

# [What is Cerberus For?](#what-is-cerberus-for)

Lorem ipsum dolor sit amet, molestie tortor sit, mauris dolore non, nec magnis ligula dolor, at sed laoreet. Sed purus
 tristique ut eu donec, vitae sodales blandit urna, ut mi aliquam donec, inceptos eros elementum sociosqu eget eu. Eros 
 elit augue tellus accumsan. Sit ut imperdiet mauris malesuada id, cras nulla curae, curabitur in odio vestibulum, tempus
  rutrum. Velit metus. Imperdiet massa facilisi integer non orci egestas, turpis in pellentesque sed, gravida morbi susp
  endisse ornare fringilla libero, id a vestibulum, blandit ut non lacus elit. Libero venenatis accumsan at hymenaeos, m
  auris faucibus interdum rutrum et, felis ullamcorper duis bibendum laoreet, faucibus vestibulum dictumst lacus ornare 
  dolor adipiscing, hac sed fermentum. Rutrum ipsum ac. Integer lectus ultricies arcu, odio in metus dictum, libero duis
   donec nec sit turpis. Libero lacus, mattis ornare nulla, tempus erat convallis vitae nunc vestibulum ac, feugiat sem 
   massa. Tristique porta, turpis diam lacus non aliquam. Non orci ultricies, vitae quis turpis vivamus felis, sed sit i
   n ante, sed ullamcorper, nunc nibh wisi id a non.

<a name="what-problem-does-cerberus-solve"></a>

# [What Problem Does Cerberus Solve?](#what-problem-does-cerberus-solve)

Lorem ipsum dolor sit amet, molestie tortor sit, mauris dolore non, nec magnis ligula dolor, at sed laoreet. Sed purus
 tristique ut eu donec, vitae sodales blandit urna, ut mi aliquam donec, inceptos eros elementum sociosqu eget eu. Eros 
 elit augue tellus accumsan. Sit ut imperdiet mauris malesuada id, cras nulla curae, curabitur in odio vestibulum, tempus
  rutrum. Velit metus. Imperdiet massa facilisi integer non orci egestas, turpis in pellentesque sed, gravida morbi susp
  endisse ornare fringilla libero, id a vestibulum, blandit ut non lacus elit. Libero venenatis accumsan at hymenaeos, m
  auris faucibus interdum rutrum et, felis ullamcorper duis bibendum laoreet, faucibus vestibulum dictumst lacus ornare 
  dolor adipiscing, hac sed fermentum. Rutrum ipsum ac. Integer lectus ultricies arcu, odio in metus dictum, libero duis
   donec nec sit turpis. Libero lacus, mattis ornare nulla, tempus erat convallis vitae nunc vestibulum ac, feugiat sem 
   massa. Tristique porta, turpis diam lacus non aliquam. Non orci ultricies, vitae quis turpis vivamus felis, sed sit i
   n ante, sed ullamcorper, nunc nibh wisi id a non.