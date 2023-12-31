echo "this is a log, not a script to run!"
exit 1
#
# VM setup on Zeus for FW.
# 20231127 - init
# 20231128 - networking
#   default network nat => dhclient gets 10.0 instead of 192.168
#   dhclient -v ens3
#   DHCPACK of 10.0.2.15 from 10.0.2.2
#
#
# https://wiki.libvirt.org/Networking.html
# https://rabexc.org/posts/how-to-get-started-with-libvirt-on
# https://superuser.com/questions/1353130/vm-got-10-0-x-x-address-instead-of-192-168-x-x-address
# https://libvirt.org/firewall.html
# https://serverfault.com/questions/1148745/libvirt-qemu-network-guest-dhclient-10-0-2-15-instead-of-192-168-122-2

# confirm cpu support
grep -m1 -Po 'vmx|vsm' /proc/cpuinfo # vmx

# if no kvm module, probalby need to install everything
lsmod | grep kvm -q ||
  sudo yum install qemu-kvm qemu-img libvirt virt-install libvirt-client libvirt-python libvirt-python

lsmod|grep kvm
#kvm_intel             188740  3
#kvm                   637289  1 kvm_intel
#irqbypass              13503  1 kvm


# update os db if we dont have the ubuntu we're going to use
if ! osinfo-query os|grep -q ubuntu22; then
    wget --no-check-certificate -O "/tmp/osinfo-db.tar.xz" \
            "https://releases.pagure.org/libosinfo/osinfo-db-20231027.tar.xz"
    sudo osinfo-db-import --local "/tmp/osinfo-db.tar.xz"
    osinfo-query os|grep ubuntu22 -i
fi

# install virtual drive. core needs 50 Gb RAM (measured in Mb) and 100Gb of disk
virt-install --dry-run --name fw-core --ram $((1024*50)) --file=/home/foranw/fw-core.img --file-size=100 --os-variant ubuntu22.04 --vnc --cdrom=./ubuntu-22.04.3-live-server-amd64.iso

virsh list --all
# Id    Name                           State
#----------------------------------------------------
# 2     fw-core                        running

# virt-viewer

# on guest
# systemctl enable serial-getty@ttyS0.service
# on host
virsh console fw-core


# no luck
virsh net-update default add ip-dhcp-host \
      "<host mac='52:54:00:6d:e4:ae' \
       name='fw-core' ip='192.168.122.2' />" \
       --live --config
# on guest/fw-core
# https://superuser.com/questions/487607/how-to-request-a-specific-ip-address-from-dhcp-server
# vi /etc/dhcp/dhclient.conf; send dhcp-requested-address 192.168.122.2;
# sudo dhclient -v ens3
# sudo firewall-cmd --add-port=53/tcp --add-port=53/udp



sudo systemctl disable --now docker k3s

# start on boot and start right now
virsh autostart fw-core
virsh start fw-core

virsh -c qemu:///session dumpxml fw-core > fw-core.xml
virsh -c qemu:///session undefine fw-core
sudo virsh -c qemu:///system define fw-core.xml


# clone and modify to create connect, utility, and analysis
virt-clone \
   --original fw-core \
   --name fw-connect \
   --file /raidzeus/vm/fw-connect.img
virsh setmaxmem fw-connect $((16*1024*1024)) --config
virsh setmem    fw-connect $((16*1024*1024)) --config
virsh setvcpus  fw-connect 4 --config --maximum
virsh setvcpus  fw-connect 4 --config
mac=$(virsh dumpxml fw-connect|grep -Po "(?<=mac\ address=')[0-9a-f:]+" ) # 52:54:00:f6:9f:b7
virsh net-update default add ip-dhcp-host \
          "<host mac='$mac' \
           name='fw-connect' ip='192.168.122.3' />" \
           --live --config
virsh start fw-connect
echo 'fw-connect'| ssh fw@192.168.122.3 sudo tee /etc/hostname



virt-clone \
   --original fw-connect \
   --name fw-util \
   --file /raidzeus/vm/fw-util.img
virsh setmaxmem fw-util $((4*1024*1024)) --config
virsh setmem    fw-util $((4*1024*1024)) --config
virsh setvcpus  fw-util 2 --config --maximum
virsh setvcpus  fw-util 2 --config
sudo qemu-img resize /raidzeus/vm/fw-util.img 100G
mac=$(virsh dumpxml fw-util|grep -Po "(?<=mac\ address=')[0-9a-f:]+" )
virsh net-update default add ip-dhcp-host \
          "<host mac='$mac' \
           name='fw-util' ip='192.168.122.4' />" \
           --live --config
virsh start fw-util
echo 'fw-util'| ssh fw@192.168.122.4 sudo tee /etc/hostname

virt-clone \
   --original fw-connect \
   --name fw-analysis \
   --file /raidzeus/vm/fw-analysis.img
virsh setmaxmem fw-analysis $((8*1024*1024)) --config
virsh setmem    fw-analysis $((8*1024*1024)) --config
virsh setvcpus  fw-analysis 8 --config --maximum
virsh setvcpus  fw-analysis 8 --config
sudo qemu-img resize /raidzeus/vm/fw-analysis.img 200G
mac=$(virsh dumpxml fw-analysis | grep -Po "(?<=mac\ address=')[0-9a-f:]+" )
virsh net-update default add ip-dhcp-host \
          "<host mac='$mac' \
           name='fw-analysis' ip='192.168.122.5' />" \
           --live --config
virsh start fw-analysis
echo 'fw-analysis'| ssh fw@192.168.122.5 sudo tee /etc/hostname


ssh fw@192.168.122.2 'sudo growpart /dev/vda 2; sudo resize2fs /dev/vda2'
