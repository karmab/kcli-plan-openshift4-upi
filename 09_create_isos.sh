echo creating isos for you
cluster={{ cluster }}
yum -y install httpd python3
systemctl enable --now httpd
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
cd /root/
COREOSINSTALLER="podman run --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release"
for role in bootstrap master worker; do
 cp /root/ocp/$role.ign config.ign
 python3 create_iso_ignition.py 
 $COREOSINSTALLER iso ignition embed -fi iso.ign rhcos-live.x86_64.iso
 cp rhcos-live.x86_64.iso /var/www/html/$cluster-$role.iso
done
