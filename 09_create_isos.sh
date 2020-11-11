echo creating isos for you
cluster={{ cluster }}
yum -y install httpd python3
sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf
systemctl enable --now httpd
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
cd /root/
if [ ! -f rhcos-live.x86_64.iso ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/4.6.1/rhcos-live.x86_64.iso > rhcos-live.x86_64.iso
fi
COREOSINSTALLER="podman run --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release"
for role in bootstrap master worker; do
 cp /root/ocp/$role.ign config.ign
 python3 create_iso_ignition.py 
 $COREOSINSTALLER iso ignition embed -fi iso.ign -o /var/www/html/$cluster-$role.iso rhcos-live.x86_64.iso
done
