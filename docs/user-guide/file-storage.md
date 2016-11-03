---
layout: documentation
title: File Storage
---

The UI of the dashboard does not yet support uploading of file contents but storing files is supported via API using
one of the Cerberus clients or even over HTTPS using curl or wget.

For example, to write a certificate and java keystore to a safe deposit box in Cerberus:

### Java Client
 
{% highlight java %}

final Map<String, String> contents = new HashMap<>();
contents.add(“certificate.cer”, “<file contents>”);
contents.add(“keystore.jks”, “<file contents>”);
vaultClient.write(“app/my-app/secrets”, contents);

{% endhighlight %}


<br />

### Over HTTPS

POST /v1/secret/app/my-app/secrets

{% highlight json %}
Host: test.cerberus.nikecloud.com
X-Vault-Token: <YOUR CERBERUS TOKEN>
Content-Type: application/json
{
	“certificate.cer”: “<file contents>”,
	“keystore.jks”: “<file contents>”
}

{% endhighlight %}



Keep in mind, that the structure of path and data is really up to the end user, what is shown above is just one of many 
ways the storage of this data could be structured.
