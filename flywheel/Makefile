.PHONY: all .ALWAYS
all: default-network.xml fw-core.xml fw-connect.xml fw-util.xml fw-analysis.xml
default-network.xml: .ALWAYS
	sudo virsh net-dumpxml default > $@
%.xml: .ALWAYS
	virsh dumpxml $(subst .xml,,$@) > $@

iptables.cmds:
	sudo iptables-save > $@
iptables.txt:
	sudo iptables -L > $@

/etc/libvirt/hooks/qemu: iptables-hook.bash 
	sudo cp $< $@
fstab: /etc/fstab
	cp $< $@
