.PHONY: all .ALWAYS
all: default-network.xml fw-core.xml fw-connect.xml fw-util.xml fw-analysis.xml
default-network.xml: .ALWAYS
	sudo virsh net-dumpxml default > $@
%.xml: .ALWAYS
	virsh dumpxml $(subst .xml,,$@) > $@

iptables.txt:
	sudo iptables-save > $@

/etc/libvirt/hooks/qemu: iptables-hook.bash 
	sudo cp $< $@
