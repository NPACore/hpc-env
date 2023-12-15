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

## Data share

NFS share from host Zeus:
```
mount 192.168.122.1:/raidzeus/flywheel/ /data/
```

requires `apt install nfs-common` on VMs.

(redhat libvirt version is too old to use virtio mounts.)

## NAT port forwarding

  * `iptables-hook.bash` is intended to by copied to `/etc/libvirt/hooks/qemu` but might [have an error](https://serverfault.com/questions/989967/cant-port-forward-with-iptables-kvm-nat)
  * `iptables.txt` (see `Makefile`) has current firewall settings
  * panic ran `systemctl stop firewalld` (20231212). not sure what willhappen when brought back up. see `firewall-cmd` in `vm_setup.bash`
  * `-d $HOST_IP` is missing in libvirt PREROUTING `iptables` networking example?


## Trouble shooting

getting around network issues with socks proxy
```
ssh -D12345 -MNf flywheel@192.168.122.1
sudo apt-get -o Acquire::http::proxy="socks5h://127.0.0.1:12345/" install git
```

