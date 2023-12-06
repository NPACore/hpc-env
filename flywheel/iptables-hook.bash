#!/bin/bash
# forward ports
#
# https://wiki.libvirt.org/Networking.html
# suggested 
#   sudo cp iptables-hook.bash  /etc/libvirt/hooks/qemu

# host: sudo ./iptables-hook.bash 192.168.122.2:8000/8000 start
# guest: restart
# guest: python3 -m http.server
# host: curl localhost:80000

# 20231205WF - init. if->case. create ip:port/hostport scheme

update_forwarding(){
 local delete_or_insert guest_ip guest_port host_port
 delete_or_insert="${1:?iptables -D/-I delete or insert}"; shift # -D or -I
 ! [[ "$1" =~ ^([0-9].*[0-9]):([0-9]+)/([0-9]+)$ ]] &&
    echo "WARNING: $1 does not match guestip:guestport/hostport" && return 1

 guest_ip="${BASH_REMATCH[1]}"
 guest_port="${BASH_REMATCH[2]}" 
 host_port="${BASH_REMATCH[3]}"

 /sbin/iptables $delete_or_insert FORWARD -o virbr0 -p tcp -d $guest_ip --dport $guest_port -j ACCEPT
 /sbin/iptables -t nat $delete_or_insert PREROUTING -p tcp --dport $host_port -j DNAT --to $guest_ip:$guest_port
}

vmname="$1"; shift
action="$1"; shift
[ -z "$action" ] &&
  echo "USAGE: $0 vnmane start|stopped|reconnect;
  vmname from 'virsh list --all' or 'guestip:guestport/hostport'" &&
  exit 1

GUEST_PORT=()
INSERT_DELETE=()

case "$vmname" in
 fw-core) GUEST_PORT=("192.168.122.2:80/80" "192.168.122.2:8000/8000");;
 # testing, DIY ip:port/hostport
 [0-9.]*:[0-9]*/[0-9]*) GUEST_PORT=("$vmname");;
 *) echo "unknown VM name '$vmname' (cannot '$action')"; exit ;;
esac

case "$action" in
   stopped)   INSERT_DELETE=("-D") ;;
   start)     INSERT_DELETE=("-I");;
   reconnect) INSERT_DELETE=("-D" "-I");;
   *) echo "unknown action '$action' (for '$vmname')"; exit;;
esac

for ip_ports_str in "${GUEST_PORT[@]}"; do
  for i_d in "${INSERT_DELETE[@]}"; do
    update_forwarding $i_d $ip_ports_str  |& tee -a /var/log/vm_qemu_iptables.log
    echo "$(date +%FT%H:%M) $i_d $ip_ports_str" >> /var/log/vm_qemu_iptables.log
  done
done
