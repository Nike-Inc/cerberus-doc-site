---
layout: documentation
title: Backup and Restore
---

If Consul enters a fugue state or is unhealthy and cannot accept requests, one
option is to erase all consul data (e.g. terminate all consul instances) and
perform a full Cerberus recovery.

This process requires the data in Consul to have been previously backed up via
the Cerberus Backup Lambda or the Cerberus CLI `create-backup` command.

Whenever we perform any maintenance on a Cerberus environment we typically open all of our
[monitoring](monitoring) tools, as well as several terminals to tail all of the logs, repeatedly run the
healthcheck, etc.  You will want to develop your own shell scripts to make it easy to perform these
activities so that you can quickly understand what is going on with the system whenever you want to dig in.

Simple preparation will help you enormously if you ever experience an actual outage.

# Reset Consul Cluster

Scale the Consul ASG down to 0 EC2 instances for the environment in need of
recovery. This can be done in two ways:


* Log in to AWS console and scale the Consul ASG down to zero
* Use the Cerberus CLI 'update-stack' command to change the min-, max-, and
  desired- instance values to zero.

Once, the Consul instances have been terminated scale the Consul ASG back to
the expected instance values (e.g. 3 min instances, 3 desired instances,
and 4 max instances). Then wait for the instances to reach "InService" status.

# Add Vault to New Consul Cluster

Reboot each EC2 instance in the Vault cluster using the AWS console.

SSH into a Vault or Consul instance and make sure that all Vault and Consul
private IPs appear in the `consul members` list:

```bash
$ consul members -http-addr http://127.0.0.1:8580 -detailed
Node             Address            Status  Tags
ip-172.1-0-101   172.1.0.101:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-0-102   172.1.0.102:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-4-156   172.1.4.156:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-4-155   172.1.4.155:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-8-61    172.1.8.61:8301    alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-8-95    172.1.8.95:8301    alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
```

** Note: Vault instances will have `role=node` in the 'Tags' column

If the Vault instances are not listed, then the Consul cluster may not have been
fully initialized before the Vault reboot. Try rebooting the Vault nodes again
to ensure they are added to the Consul cluster.

# Start a SOCKS Proxy

If you require a proxy to talk to Cerberus EC2 instances then you will want to
start it now and use it in the commands below.

# Add Certificates to Trust Store

Add the Vault certificate in DER (*.cer) format to your Java trust store:

```bash
$ keytool -import-keystore /path/to/JDK/jre/lib/security/cacerts -storepass changeit -noprompt -trustcacerts -alias [certificate name] -file /path/to/der/file/[download_name].cer
```

# Initialize Vault

In a new Terminal tab run the following CLI command:

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
        --proxy-port 9001 \
    init-vault-cluster
```

** Note: This command requires admin AWS credentials for Cerberus to be set up
in the Terminal environment.

## Troubleshooting:

* If Vault returns a 400 status code like below, then make sure the 'token' value
in the 'data/vault/vault-config.json' file matches the value in the
'vault_acl_token' value in the 'config/consul/secrets.json' file in S3.

    ```
    responseCode=400,
    requestUrl=https://<ip-addr>.<aws-region>.compute.amazonaws.com:8200/v1/sys/init,
    response={"errors":["failed to check for initialization: Unexpected response code: 403"]}
    ```

    If the values token values in the two files mentioned aboved do not match, run
    the 'create-vault-config' CLI command and reboot the Vault instances in the AWS
    console. If you still get a 403 error, then reboot the nodes in your Consul
    cluster as well.

* If Vault returns a 500, then Vault may still be starting up. Give it a minute or
two and try again.

# Unseal Vault Cluster

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9001 \
    unseal-vault-cluster
```

# Load Default Vault Policies

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9001 \
    load-default-policies
```

# Create New CMS Vault Token

You may need to revoke the old CMS Vault token after the new token is generated.
You can take note of the token before running this command or check previous
versions of the 'data/cms/environment.json' file in S3.

You may want to avoid 'force-overwrite' in a production system, unless the
system is already in a broken state.

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9001 \
    create-cms-vault-token \
    --force-overwrite
```

# Update CMS Config

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    update-cms-config
```

# Reboot CMS instances

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9001 \
    rolling-reboot \
    --stack-name CMS
```

# Restore from Backup

This command requires AWS credentials with permissions to decrypt the KMS key
used to encrypt the specified Cerberus backup file:

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    --proxy-type SOCKS \
    --proxy-host localhost \
    --proxy-port 9001 \
    restore-complete \
    -s3-bucket <backup-bucket-name> \
    -s3-prefix <path-to-backup> \
    -s3-region us-east-1 \
    -url https://cerberus-env-url.com
```

# References

* <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/index.html')" href="https://www.consul.io/docs/index.html">Consul Documentation</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/commands/index.html')" href="https://www.consul.io/docs/commands/index.html">Consul CLI</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/guides/outage.html')" href="https://www.consul.io/docs/guides/outage.html">Consul Outage Recovery</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/guides/servers.html ')" href="https://www.consul.io/docs/guides/servers.html">Adding/Removing Consul Servers</a>
* <a target="_blank" onclick="trackOutboundLink('https://github.com/hashicorp/consul')" href="https://github.com/hashicorp/consul">Consul Github</a>
* <a target="_blank" onclick="trackOutboundLink('https://www.vaultproject.io/docs/index.html')" href="https://www.vaultproject.io/docs/index.html">Vault Documentation</a>
