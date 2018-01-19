---
layout: documentation
title: Creating Certificates using Venafi
---

If you are using Venafi, after creating the certificate in the UI,

1. Download the Certificate
   1. Choose DER format (later this file will be used to import into your Java trust store)
1. Download the Certificate again
   1. Choose PEM/OpenSSL format
   1. Include the Root Chain and Private Key by checking all of the checkboxes
   1. Choose the default Chain Order "End Entity First"
   1. Enter a pass phrase
1. The resulting download has four sections, break it up into three files:
   1. Section 1 goes in a file named cert.pem
   1. Section 2 and 3 go in a file named ca.pem
   1. Section 4 goes in a file named privkey.pem
1. Run the following commands to extract the private and public keys (you will be prompted for the pass phrase entered earlier):
   1. `openssl rsa -in privkey.pem -pubout > pubkey.pem`
   1. `openssl rsa -in privkey.pem -out key.pem`
   1. `openssl pkcs8 -topk8 -nocrypt -in key.pem -out pkcs8_key.pem`

### Make Certificate Usable by Cerberus

Once the certificate is created, we will need to ensure the following files are together in one directory for the CLI
to reference:

file          | purpose
------------- | --------------------------------
pubkey.pem    | the public key
key.pem       | the private key
pkcs8_key.pem | the private key in pkcs8 format
ca.pem        | the certificate authority key
cert.pem      | the cert

<a name="add-ca"></a>

### Add the CA to your java trust store.

You will most likely need to add your CA to the Java trust store, unless the JVM trusts it already by default, e.g.

    keytool -import -keystore PATH_TO_JDK\jre\lib\security\cacerts -storepass changeit -noprompt -trustcacerts -alias [ALAIS] -file PATH_TO_DOWNLOADS\[CA].der

Find the current Java on MacOS with `/usr/libexec/java_home`.