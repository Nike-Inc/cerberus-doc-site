---
layout: documentation
title: Backup and Restore
---

# Backup

Different components of Cerberus can be backed up independently e.g. RDS backups are 
scheduled in the AWS console, Consul data files are automatically backed up in S3
under the `config` bucket under the path `/consul/backups`, but the main backup for a 
Cerberus system is created with the `create-backup` command in the CLI.  This command
can be used to create a full export of secrets and SDB meta data, which is then encrypted
using KMS, and stored in S3 in a different region than the Cerberus environment.

# Restore

A backup created via the `create-backup` command can be applied to a Cerberus system using
the `restore-complete` command.  These two commands can also be used to copy all of the data
from one Cerberus environment to another.

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
    -s3-region <region-where-backup-is-stored> \
    -url https://cerberus-env-url.com
```

If the overall system is not healthy enough to accept a restore, it is possible to
reinitialize most of the system by following the procedure outlined below.

# Reinitializing Cerberus

This procedure is helpful if a Cerberus environment has stopped working.
For example, sometimes during development and testing an environment is destroyed.
Maybe Consul or Raft has entered a fugue state and the system is still not working after 
attempting [Consul Recovery](consul-recovery).  Rather than rebuilding the environment
from scratch, it can usually be reinitialized using the following steps.

## 1. Prerequisite Steps

1. If you require a proxy to reach the Cerberus EC2 instances then start it now and
use it in the commands below.

2. Export admin AWS credentials for Cerberus in your terminal environment.

3. Add the Vault certificate in DER (*.cer) format to your Java trust store.

```bash
$ keytool -import-keystore /path/to/JDK/jre/lib/security/cacerts -storepass changeit -noprompt -trustcacerts -alias [certificate name] -file /path/to/der/file/[download_name].cer
```

You may have already completed this step during installation of Cerberus.

## 2. Reset Consul cluster

1. Scale the Consul AutoScalingGroup (ASG) down to 0 EC2 instances and wait for them to be terminated.
1. Scale the Consul ASG back up to the expected instance values (e.g. 3 min instances, 3 desired instances,
and 4 max instances). Then wait for the instances to reach "InService" status.

This step should produce a newly initialized and functional Consul cluster with no data.

## 3. Add Vault to new Consul cluster

1. Reboot each EC2 instance in the Vault cluster using the AWS console so that they can join
   the newly created Consul cluster.
1. SSH into a Vault or Consul instance and make sure that all Vault and Consul
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

## 4. Initialize Vault

Run the following CLI command:

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

### Troubleshooting

* If Vault returns a 400 status code like below, then make sure the 'token' value
in the `data/vault/vault-config.json` file matches the value in the
'vault_acl_token' value in the `config/consul/secrets.json` file in S3.

    ```
    responseCode=400,
    requestUrl=https://<ip-addr>.<aws-region>.compute.amazonaws.com:8200/v1/sys/init,
    response={"errors":["failed to check for initialization: Unexpected response code: 403"]}
    ```

    If the values token values in the two files mentioned aboved do not match, run
    the `create-vault-config` CLI command and reboot the Vault instances in the AWS
    console. If you still get a 403 error, then reboot the nodes in your Consul
    cluster as well.

* If Vault returns a 500, then Vault may still be starting up. Give it a minute or
two and try again.

## 5. Unseal Vault cluster

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

## 6. Load default Vault policies

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

## 7. Create new CMS Vault token

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

This command will warn that the old CMS Vault token may need to be revoked but since
the cluster has been wiped out, it no longer exists.

## 8. Update CMS Config

```bash
cerberus \
    -e dev \
    -r us-west-2 \
    --debug \
    update-cms-config
```

## 9. Reboot CMS instances

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

## 10. Restore from Backup

This command requires AWS credentials with permissions to decrypt using the KMS key
that was used to encrypt the specified Cerberus backup file:

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
