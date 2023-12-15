# make sure we haven't killed network access for VMs
# resolved by adding '-d HOST_IP' to PREROUTE iptables command
# see iptables-hook.bash
brctl show
sudo bridge fdb show dev vnet0

sudo timeout 2s tcpdump -ni virbr0 'tcp port 80' > /tmp/tcpdump_vm_curl.txt &
echo "google from vm:"
ssh fw@fw-core curl -m1 -s google.com|sed 1q
echo "fw http from rhea:"
ssh rhea curl -m1 -s fw.mrrc.upmc.edu|sed 1q
echo "fw from localhost:"
nmap -p 80,443 fw.mrrc.upmc.edu|grep ^[84]
echo "fw from rhea:"
ssh rhea nmap -p 80,443 fw.mrrc.upmc.edu|grep ^[84]
# no nmap on fw-core
#echo "fw within vm:"
#ssh fw@fw-core nmap -p 80,443 fw.mrrc.upmc.edu|grep ^[84]
 
