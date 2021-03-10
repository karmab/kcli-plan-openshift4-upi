cluster={{ cluster }}
dir=/root/ocp
BASE="/tmp/base.iso"
IP={{ machine_cidr|network_ip(1) }}
echo $IP | grep -q ':' && IP=[$IP]
PORT=8080
WEBDIR="/var/www/html"
ROOTFS="http://$IP:$PORT/rootfs.img"

cd /root
if [ ! -f $WEBDIR/rootfs.img ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live-rootfs.x86_64.img  > $WEBDIR/rootfs.img
fi

dnf -y install httpd python3 git mkisofs syslinux xorriso
sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf
systemctl enable --now httpd
if [ ! -f rhcos-live.x86_64.iso ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live.x86_64.iso > rhcos-live.x86_64.iso
fi
curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.6.1-x86_64-live-rootfs.x86_64.img > /var/www/html/rootfs.img

git clone https://github.com/redhat-ztp/ztp-iso-generator.git 
for role in bootstrap master worker; do
 OUTPUT="$WEBDIR/$cluster-$role.iso"
 IGNITION_FILE="http://$IP:$PORT/$role-iso.ign"
 KERNEL_ARGS="coreos.inst.install_dev=vda coreos.inst=yes coreos.inst.ignition_url=$IGNITION_FILE"
 echo Creating iso for $role
 if [ "$role" == "bootstrap" ] ; then
   cp $dir/$role.ign config.ign
 else
   export ROLE=$role
   envsubst < /root/ignition.template > config.ign
 fi
 python3 create_iso_ignition.py
 cp iso.ign /var/www/html/$role-iso.ign
 rm -rf $BASE $OUTPUT /tmp/syslinux* /tmp/coreos
 cd ztp-iso-generator/rhcos-iso
 bash generate_rhcos_iso.sh $BASE
 bash inject_config_files.sh $BASE $OUTPUT $IGNITION_FILE $ROOTFS "$KERNEL_ARGS"
 cd /root
done
