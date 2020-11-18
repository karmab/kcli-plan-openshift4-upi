CLUSTER=cnf10
POOL=/var/lib/libvirt/images
IP=$(kcli info vm $CLUSTER-installer -f ip -v)
cd $POOL
rm -rf $CLUSTER-*.iso
wget http://$IP:8080/$CLUSTER-bootstrap.iso
wget http://$IP:8080/$CLUSTER-master.iso
wget http://$IP:8080/$CLUSTER-worker.iso
