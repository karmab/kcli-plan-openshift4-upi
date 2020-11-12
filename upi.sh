IP=$(kcli info vm upi-installer -f ip -v)
POOL=$(kcli list pool | grep default | awk -F'|' '{print $3}' | xargs)
cd $POOL
rm -rf upi*iso
wget http://$IP:8080/upi-bootstrap.iso
wget http://$IP:8080/upi-master.iso
wget http://$IP:8080/upi-worker.iso
