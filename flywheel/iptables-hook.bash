#!/bin/bash
# forward ports
#
# https://wiki.libvirt.org/Networking.html
# suggested 
#   sudo cp iptables-hook.bash  /etc/libvirt/hooks/qemu

# host: sudo ./iptables-hook.bash 192.168.122.2:8000/8000 start
# guest: python3 -m http.server
# host: curl localhost:8000
#
# changes from libvirt example:
#  - ADD HOST IP AS DESTINATION. otherwise will eat all traffic on the port for all vms
#    without this change, after forwarding port 80, 'curl google.com' would time out from within any VM
#  - build actions and hosts separatly/independently
#    use bash array to store multiple ports to forward

# also see
# https://github.com/doccaz/kvm-scripts/blob/master/qemu-hook-script

# 20231205WF - init. if->case. create ip:port/hostport scheme
# 20231214WF - add '-d HOST_IP' to DNAT. otherwise all traffic on desired port is eaten

LOG=/var/log/vm_qemu_iptables.log

# if not defined, try to get it with dig
[ ! -v HOST_IP ] && HOST_IP="$(dig +short fw.mrrc.upmc.edu)"

if ! [[ $HOST_IP =~ ^[0-9.]+$ ]]; then
  echo "ERROR: Invalid HOST_IP ('$HOST_IP'). "\
       "Cannot run. Try 'HOST_IP=xx.xx.xx.xx $0 $@'" | tee -a $LOG
  exit 1
fi

# also add VM host ip destition so forwading applies within the VM network too
HOST_IP=("$HOST_IP") # "192.168.122.1")

update_forwarding(){
 local del_or_ins guest_ip guest_port host_port
 del_or_ins="${1:?iptables -D/-I delete or insert}"; shift # -D or -I

 ! [[ "$1" =~ ^([0-9].*[0-9]):([0-9]+)/([0-9]+)$ ]] &&
    echo "WARNING: $1 does not match guestip:guestport/hostport" && return 1

 guest_ip="${BASH_REMATCH[1]}"
 guest_port="${BASH_REMATCH[2]}" 
 host_port="${BASH_REMATCH[3]}"
 local host_ip=$guest_ip
 local guest_nic=virbr0

 for host_ip in "${HOST_IP[@]}"; do
   set -x
   /sbin/iptables        $del_or_ins FORWARD -o virbr0 -p tcp -d $guest_ip --dport $guest_port -j ACCEPT
   /sbin/iptables -t nat $del_or_ins PREROUTING        -p tcp -d $host_ip  --dport $host_port  -j DNAT --to $guest_ip:$guest_port
   { set +x; } 2>&-
 done

}

vmname="$1"; shift
action="$1"; shift
[ -z "$action" ] &&
  echo "USAGE: $0 vnmane start|stopped|reconnect;
  vmname from 'virsh list --all' or 'guestip:guestport/hostport'" &&
  exit 1

GUEST_PORT=()
INSERT_DELETE=()


# build list of ports to forward based on input vmname
case "$vmname" in
 fw-core)
   GUEST_PORT=("192.168.122.2:80/80"
               "192.168.122.2:443/443");;

 # testing, DIY ip:port/hostport
 [0-9.]*:[0-9]*/[0-9]*)
   GUEST_PORT=("$vmname");;

 *)
   echo "Unknown VM name '$vmname' or no firewall settings. "\
        "Nothing to do for action '$action'. "\
        'See `virsh list --all` for vm-names. "\
        "Or use "ip:gport/hport"' |tee $LOG; exit ;;
esac

# build list of actions to take (reconnect deletes and inserts)
case "$action" in
   stopped)   INSERT_DELETE=("-D") ;;
   start)     INSERT_DELETE=("-I");;
   reconnect) INSERT_DELETE=("-D" "-I");;
   *) echo "Unknown action '$action' for '$vmname'. "\
           "Action must be 'start', 'stopped' or 'reconnect'" |
   tee $LOG; exit;;
esac

# run all the comands we've built up
for ip_ports_str in "${GUEST_PORT[@]}"; do
  for i_d in "${INSERT_DELETE[@]}"; do
    update_forwarding $i_d $ip_ports_str  |& tee -a $LOG
    echo "$(date +%FT%H:%M) $i_d $ip_ports_str" >> $LOG
  done
done


# -D, --delete chain rule-specification
# -D, --delete chain rulenum
#        Delete  one  or more rules from the selected chain.  There are
#        two versions of this command: the rule can be specified  as  a
#        number  in  the  chain (starting at 1 for the first rule) or a
#        rule to match.
# 
# -I, --insert chain [rulenum] rule-specification
#        Insert one or more rules in the selected chain  as  the  given
#        rule  number.   So, if the rule number is 1, the rule or rules
#        are inserted at the head of the chain.  This is also  the  de‐
#        fault if no rule number is specified.
#
#  -t, --table table
#        This option specifies the packet matching table which the com‐
#        mand should operate on.  If the kernel is configured with  au‐
#        tomatic  module  loading,  an attempt will be made to load the
#        appropriate module for that table if it is not already there.
#        nat:
#         This table is consulted when a packet that creates  a  new
#         connection is encountered.  It consists of four built-ins:
#         PREROUTING (for altering packets as soon as they come in)
#        filter:
#          This is the default table (if no -t option is passed).  It
#          contains  the  built-in chains INPUT (for packets destined
#          to local  sockets),  FORWARD  (for  packets  being  routed
#          through  the box), and OUTPUT (for locally-generated pack‐
#          ets).
#
# -j, --jump target
#        This specifies the target of the rule; i.e., what to do if the
#        packet matches it.  The target can  be  a  user-defined  chain
#        (other  than  the  one  this  rule  is in), one of the special
#        builtin targets which decide the fate of  the  packet  immedi‐
#        ately, or an extension (see EXTENSIONS below).  If this option
#        is  omitted  in a rule (and -g is not used), then matching the
#        rule will have no effect on the packet's fate, but  the  coun‐
#        ters on the rule will be incremented.
# [!] -o, --out-interface name
#        Name of an interface via which a packet is going  to  be  sent
#        (for  packets  entering  the  FORWARD,  OUTPUT and POSTROUTING
#        chains).  When the "!" argument is used before  the  interface
#        name,  the sense is inverted.  If the interface name ends in a
#        "+", then any interface  which  begins  with  this  name  will
#        match.   If  this  option  is omitted, any interface name will
#        match.
#      [!] -d, --destination address[/mask][,...]
#             Destination  specification.   See  the  description  of  the  -s (source) flag for a
#             detailed description of the syntax.  The flag --dst is an alias for this option.
#
#          Address can be either a network name, a hostname, a network IP
#             address  (with  /mask), or a plain IP address

#
#
#
#  ACCEPT  means  to  let  the  packet  through.
#  DROP means to drop the packet on the floor.
# 
# 
#  Destination NAT (DNAT) is a feature in iptables that allows you to rewrite the destination address of packets as they pass through the firewall. It's commonly used in scenarios such as port forwarding or redirecting incoming traffic to a specific internal IP address and port.
