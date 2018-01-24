---
layout: documentation
title: Troubleshooting
---

# Who am I?

A frequent first troubleshooting step is validating the role assigned to an SDB is the actual role being used by your application.

## Use the AWS Metadata endpoint

Look up your role name by curling the [meta-data endpoint](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval) for your ec2 instance:

```bash
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

Look up your instance-profile ARN by curling the metadata endpoint:

```bash
curl -s http://169.254.169.254/latest/meta-data/iam/info
```

## Use the AWS CLI

With the role name you can get the full ARN of the role with:

```bash
aws iam get-role --role-name <role-name>
```

The role ARN for an instance profile can also be looked up using this command:

```bash
aws iam get-instance-profile --instance-profile-name <instance-profile-name>
```

Get your assumed-role identity with this command:

```bash
aws sts get-caller-identity
```


# Dependency Conflicts

Another common problem is dependency conflicts.

## Java Gradle Projects

Use these commands to see the Cerberus client version that is actually being resolved in a Java Gradle project:

```bash
./gradlew dependencyInsight --dependency cerberus
./gradlew dependencyInsight --dependency vault
./gradlew dependencyInsight --dependency okhttp
./gradlew dependencies
```

Learn more in the [Gradle User Guide](https://docs.gradle.org/current/userguide/dependency_management.html).

## Java Maven Projects

Debug Maven dependency conflicts using the [dependency:tree](https://maven.apache.org/plugins/maven-dependency-plugin/examples/resolving-conflicts-using-the-dependency-tree.html) command.

# Permission Denied

#### E.g. com.nike.cpe.vault.client.VaultServerException: Response Code: 400, Messages: permission denied

The SDB you are trying to access may need permissions updated.  For example, you will get this error if the IAM
role being used isn't listed for the SDB you are trying to access (see 'Who am I?' above).

Unexpectedly, you might also see this error when the path you are trying to access doesn't exist.

# Excessive Polling

IPs making an excessive number of requests are automatically blacklisted for a configurable interval.

When using polling be sure to use a reasonable interval as determined by your organization.


# SSL Handshake Failure

#### E.g. javax.net.ssl.SSLHandshakeException: Received fatal alert: handshake_failure

#### E.g. java.net.UnknownServiceException: Unable to find acceptable protocols.

This error may mean your client is not compatible with TLS1.2, possibly due to being on an old version of Java
or other older library.

#### Minimum Java versions for TLS1.2

* Java 9 any version - enabled by default
* Java 8 any version - enabled by default
* Java 7 update 131 (Oracle paid version) - added TLS1.2 to the client list of default-enabled protocols (see the [Release Notes](http://www.oracle.com/technetwork/java/javaseproducts/documentation/javase7supportreleasenotes-1601161.html))
* Java 7 update 80 (last public version) - added TLS1.2 support to clients that is enabled via a system property
* Java 6 update 141 (Oracle paid version) - added TLS1.2 to the client list of default-enabled protocols (see the [Release Notes](http://www.oracle.com/technetwork/java/javase/overview-156328.html)
* Java 6 update 115 (Oracle paid version) - added TLS1.2 support to clients that is enabled via a system property (see the [Release Notes](http://www.oracle.com/technetwork/java/javase/overview-156328.html))

Java 7 example code available [here](https://github.com/Nike-Inc/cerberus-java-client/pull/33).

#### JettyEclipseRun Conflict

We've also seen this during local development as result of a library conflict with the
<a target="_blank" onclick="trackOutboundLink('https://github.com/Khoulaiz/gradle-jetty-eclipse-plugin')" href="https://github.com/Khoulaiz/gradle-jetty-eclipse-plugin">jettyEclipseRun</a> Gradle plugin.  Upgrading to the
<a target="_blank" onclick="trackOutboundLink('https://github.com/akhikhl/gretty')" href="https://github.com/akhikhl/gretty">Gretty</a> plugin resolved.


# SSL Plaintext Connection Error

#### E.g. javax.net.ssl.SSLException: Unrecognized SSL message, plaintext connection?

During local development this may be due to a web proxy.  This is common in corporate environments and when working over a VPN.


# Outdated AWS SDK

#### E.g. com.amazonaws.util.EC2MetadataUtils methodname=getIAMSecurityCredentials Unable to process the credential, com.amazonaws.util.json.JSONException: Failed to instantiate class

You are probably using an older version of the AWS SDK.

### Gradle

Gradle users can see how dependencies are being resolved with the `gradle dependencies` command.

You can force a newer version by adding the following into your build.gradle

```groovy
// Use the newest version you can, this was current when we wrote this
final String AWS_SDK_VERSION = '1.10.5'
//noinspection GroovyAssignabilityCheck
configurations.all {
    resolutionStrategy {
        // add a dependency resolve rule
        eachDependency { DependencyResolveDetails details ->
            //Force use of certain dependencies or versions
            if (details.requested.group == 'com.amazonaws') {
                details.useVersion(AWS_SDK_VERSION)
            }
        }
    }
}
```

### Maven

Maven users can use the <a target="_blank" onclick="trackOutboundLink('http://maven.apache.org/plugins/maven-dependency-plugin/tree-mojo.html')" href="http://maven.apache.org/plugins/maven-dependency-plugin/tree-mojo.html">dependency tree</a>
plugin to learn more about how dependencies are being resolved.


# cerberus-token.sh

#### 301 Moved Permanently error during Auth call

This showed up when a new version of <a target="_blank" onclick="trackOutboundLink('https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh')" href="https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh">cerberus-token.sh</a> that depended on `/v2/auth/user` was used with
an old version of CMS that only implemented `/v1/auth/user`.

#### Null token during local development

This issue has showed up when an old version of <a target="_blank" onclick="trackOutboundLink('https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh')" href="https://raw.githubusercontent.com/Nike-Inc/cerberus/master/docs/user-guide/cerberus-token.sh">cerberus-token.sh</a> was
used with a newer version of Cerberus that included Multi-Factor Authentication (MFA).
