# NFS Mounts
[2023-10-04] Want both head and nodes to know about `zeus:/raidzeus/` and, separetly, head to serve guix and assocated mounts (`/var/guix`, `/gnu/store`, `/var/log/guix`).

## BrightView
  * exports for nfs on head (guix) in ["FSParts"](https://10.48.88.160:8081/bright-view/#/j1/FSParts/default)
  * nfs mounts in ["Catagory>default>FSMounts"](https://10.48.88.160:8081/bright-view/#/j1/categories/default/j2/categories/12884901889/settings/j3/fSMounts/default)

### Issues
Guix mounts need to be in the same group as the nodes (`internalnet`). When the mount's "network" was set to `globalnet`, nodes could not see/mount.

### remote access
Remote access through a web browser without needing to X11Forward is a SOCKS Proxy away:

1. mutltijump ssh with socks proxy: `ssh -J reese,mrrc-zues cerebro2 -D 12345`
2. firefox w/socks proxy `locahost:12345` (see the excellent [sidebery](https://addons.mozilla.org/en-US/firefox/addon/sidebery/) + containers for tab specific proxy)

### cmsh
CLI also exists and is usable without a socks proxy. But it has fewer guardrails and less UI to guide settings. The `cmsh` config shell needs to be `module load`ed first. 

```
module load cmsh
cmsh
  device; fsmounts node07; list
```



## Guix
https://guix.gnu.org/cookbook/en/html_node/Setting-Up-a-Head-Node.html


## Zeus
zeus's firewall was blocking connections. With that open, `nfs-server` and `rpcbind` systemd services were accessible on cerebro

```
sudo firewall-cmd --add-port=111/tcp --add-port=111/udp --add-port=2049/tcp --add-port=2049/udp
systemctl enable --now nfs-server rpcbind
```

### exportsfs
`/etc/exports` looks like
```
/raidzeus   *(rw,async)
```

### Errors

`rpcinfo`, `exportfs`, `ping`, `showmount`, and `iptables` are all useful for debuging the NFS server

```
rpcinfo -p | grep nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    3   udp   2049  nfs_acl

sudo exportfs -v
# /raidzeus       <world>(async,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

ping -c1 cerebro2.cm.cluster 
# 64 bytes from cerebro2.cm.cluster (10.48.88.160): icmp_seq=1 ttl=61 time=1.03 ms

showmount -e cerebro2.cm.cluster
# clnt_create: RPC: Port mapper failure - Unable to receive: errno 111 (Connection refused)

rpcinfo -p cerebro2.cm.cluster
# rpcinfo: can't contact portmapper: RPC: Remote system error - Connection refused

sudo iptables -L |grep nfs -i
# ACCEPT     tcp  --  anywhere             anywhere             tcp spt:nfs
# ACCEPT     udp  --  anywhere             anywhere             udp spt:nfs
# ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:nfs
# ACCEPT     udp  --  anywhere             anywhere             udp dpt:nfs
# ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:nfs ctstate NEW,UNTRACKED
# ACCEPT     udp  --  anywhere             anywhere             udp dpt:nfs ctstate NEW,UNTRACKED
```


