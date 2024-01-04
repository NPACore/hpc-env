# Flywheel config at Pitt/MRRC

  * `vm-info.bash`: virtual machine (libvirt/qemu) setup and experiments
  * `Makefile`: generate `*.xml` configuration dumps for version control

## Setup
^VM/host ^ IP ^
|vm host (zeus ) | 192.168.122.1; 10.48.86.33|
|fw-core | 192.168.122.2 |
|fw-connect |192.168.122.3 |
|fw-util |192.168.122.4 |
|fw-analysis | 192.168.122.5 |

## Image location

Images stored on xfs NVMe mount `/nvme-vm/fw/*img`. See `<source file=*img>` in `fw-*.xml` and [`log/img-to-nvme.md`](log/img-to-nvme.md). [`fstab`](fstab) has all mounts on `Zeus`

## Data share

NFS share from host Zeus:
```
mount 192.168.122.1:/raidzeus/flywheel/ /data/
```

 * redhat libvirt version is too old to use virtio mounts.
 * requires `apt install nfs-common` on VMs.
 * see setup_nfs.bash for disabling firewalld nfs block (internal zone, separate from `../docs/nfs_mounts.md`)

## NAT port forwarding

As of 2023-12-14, remote connections to `Zeus` (VM host, `fw.mrrc.upmc.edu`) on port `80` or `443` are forwarded to `fw-core` (`192.168.122.2`, see `default-network.xml`).

From zeus itself, fw.mrrc.upmc.edu resolves to localhost and will not find a running httpd. Instead, use `192.168.122.2`/`fw-core` to find http/s servers.
Similarly, from fw-core fw.mrrc.upmc.edu:80 points to zeus (no iptables virtbr0 80+443 rules). Current kludge: `fw-core:/etc/hosts` has fw.mrrc.upmc.edu point to localhost.

### Notes

  * `iptables-hook.bash` is intended to by copied to `/etc/libvirt/hooks/qemu` but might [have an error](https://serverfault.com/questions/989967/cant-port-forward-with-iptables-kvm-nat)
  * `iptables.txt` (see `Makefile`) has current firewall settings
  * panic ran `systemctl stop firewalld` (20231212). not sure what will happen when brought back up. see `firewall-cmd` in `vm_setup.bash`
  * `-d $HOST_IP` is missing in libvirt PREROUTING `iptables` networking example?
  * `iptables -t nat -I OUTPUT -p tcp -d 10.48.86.33 --dport 80 -j DNAT --to 192.168.122.2:80` (OUTPUT not PREROUTING) enables `curl fw.mrrc.upmc.edu` from zues itself. not scripted. no hook


## Trouble shooting

getting around network issues with socks proxy
```
ssh -D12345 -MNf flywheel@192.168.122.1
sudo apt-get -o Acquire::http::proxy="socks5h://127.0.0.1:12345/" install git
```

