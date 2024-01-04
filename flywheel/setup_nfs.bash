# 20240104 - NFS export /raidzeus used from fw-core vm
#            used to share certs to vm. see setup_ssl.bash
# also see ../docs/nfs_mounts.md
echo "NFS setup documetation only"
exit 1

sudo firewall-cmd --permanent --add-service=nfs --add-service=mountd --add-service=rpc-bind --zone=internal
sudo firewall-cmd --reload 

# cat /etc/exportfs
# /raidzeus   *(rw,async)


