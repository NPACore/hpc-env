# Move QEmu images to large NVMe (20231221)


## New filesystem

Make and mount new filesystem on NVMe
```
mkfs.xfs /dev/nvme0n1
mount /dev/nvme0n1 /nvme-vm
mkdir /nvme-vm/fw
```

update fstab to automout
```
grep nvme /etc/fstab
/dev/nvme0n1    /nvme-vm        xfs     defaults        0 0
```

## VMs
Turn off all the VMs
```
paralell virsh shutdown ::: fw-{core,connect,util,analysis}
```
Move (and backup) virtual machines
```
/raidzeus/vm/
mkdir bak
mv *img bak/
cp bak/*img /nvme-vm/fw
ln -s /nvme-vm/fw nvme-on-zeus
```


Update VM config for each and relaunch. Could this be done without manually editing each config file?
```
paralell virsh edit ::: fw-{core,connect,util,analysis} # replace image location with /nvme-vm/fw/*img
paralell virsh start ::: fw-{core,connect,util,analysis}
```
