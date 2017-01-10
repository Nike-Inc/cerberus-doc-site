---
layout: documentation
title: Consul Recovery
---

Consul is a distributed highly available system and can be used as the storage backend for Vault.
Within Cerberus, encrypted secrets are stored in Vault/Consul while RDS is used for Safe Deposit
Box (SDB) meta data.

Do not wait for an outage before practicing the recovery process described in the 
<a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/guides/outage.html')" href="https://www.consul.io/docs/guides/outage.html">Outage Recovery guide</a>,
including both the force-leave and manual recovery process using peers.json.

You will also want to familiarize yourself with the Consul <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/commands/index.html')" href="https://www.consul.io/docs/commands/index.html">CLI</a>. For 
example, the <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/commands/members.html')" href="https://www.consul.io/docs/commands/members.html">members command</a> displays both client and
server members of the consul cluster:

```bash
$ consul members
Node             Address            Status  Type    Build  Protocol  DC
ip-172-1-0-101   172.1.0.101:8301   alive   client  0.6.4  2         cerberus
ip-172-1-0-102   172.1.0.102:8301   alive   server  0.6.4  2         cerberus
ip-172-1-4-156   172.1.4.156:8301   alive   server  0.6.4  2         cerberus
ip-172-1-4-155   172.1.4.155:8301   alive   client  0.6.4  2         cerberus
ip-172-1-8-61    172.1.8.61:8301    alive   server  0.6.4  2         cerberus
ip-172-1-8-94    172.1.8.94:8301    alive   client  0.6.4  2         cerberus
```

In this output we can see that there are three Consul server nodes and three Vault client nodes.

```bash
$ consul members -detailed
Node             Address            Status  Tags
ip-172.1-0-101   172.1.0.101:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-0-102   172.1.0.102:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-4-156   172.1.4.156:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-4-155   172.1.4.155:8301   alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-8-61    172.1.8.61:8301    alive   build=0.6.4:32a1ed7c,dc=cerberus,expect=3,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=1
ip-172.1-8-95    172.1.8.95:8301    alive   build=0.6.4:32a1ed7c,dc=cerberus,role=node,vsn=2,vsn_max=3,vsn_min=1
```

The <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/commands/info.html')" href="https://www.consul.io/docs/commands/info.html">info command</a> also 
includes helpful output.  For example, running this command on multiple consul servers and viewing the 
raft index numbers will tell you if the servers are synchronized, and if not, repeatedly running the 
command will allow you to watch a member catch up.

```bash
$ consul info
agent:
	check_monitors = 0
	check_ttls = 0
	checks = 0
	services = 1
build:
	prerelease = 
	revision = 26a0ef8c
	version = 0.6.4
consul:
	bootstrap = false
	known_datacenters = 1
	leader = true
	server = true
raft:
	applied_index = 883924
	commit_index = 883924
	fsm_pending = 0
	last_contact = 0
	last_log_index = 883924
	last_log_term = 383
	last_snapshot_index = 879050
	last_snapshot_term = 383
	num_peers = 2
	state = Leader
	term = 383
runtime:
	arch = amd64
	cpu_count = 1
	goroutines = 82
	max_procs = 1
	os = linux
	version = go1.6
serf_lan:
	encrypted = true
	event_queue = 0
	event_time = 24
	failed = 0
	intent_queue = 0
	left = 0
	member_time = 12
	members = 6
	query_queue = 0
	query_time = 1
serf_wan:
	encrypted = true
	event_queue = 0
	event_time = 1
	failed = 0
	intent_queue = 0
	left = 0
	member_time = 1
	members = 1
	query_queue = 0
	query_time = 1
```

Whenever we perform any maintenance on a Cerberus environment we typically open all of our 
[monitoring](monitoring) tools, as well as several terminals to tail all of the logs, repeatedly run the
healthcheck, etc.  You will want to develop your own shell scripts to make it easy to perform these 
activities so that you can quickly understand what is going on with the system whenever you want to dig in. 

Simple preparation will help you enormously if you ever experience an actual outage.

# References

* <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/index.html')" href="https://www.consul.io/docs/index.html">Consul Documentation</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/commands/index.html')" href="https://www.consul.io/docs/commands/index.html">Consul CLI</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/guides/outage.html')" href="https://www.consul.io/docs/guides/outage.html">Consul Outage Recovery</a>
  * <a target="_blank" onclick="trackOutboundLink('https://www.consul.io/docs/guides/servers.html ')" href="https://www.consul.io/docs/guides/servers.html">Adding/Removing Consul Servers</a>
* <a target="_blank" onclick="trackOutboundLink('https://github.com/hashicorp/consul')" href="https://github.com/hashicorp/consul">Consul Github</a>
* <a target="_blank" onclick="trackOutboundLink('https://www.vaultproject.io/docs/index.html')" href="https://www.vaultproject.io/docs/index.html">Vault Documentation</a>

