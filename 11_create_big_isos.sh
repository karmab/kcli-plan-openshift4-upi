cluster={{ cluster }}
dir=/root/ocp

cd /root/
dnf -y install httpd python3
sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf
systemctl enable --now httpd
if [ ! -f rhcos-live.x86_64.iso ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live.x86_64.iso > rhcos-live.x86_64.iso
fi
COREOSINSTALLER="podman run --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release"
export API_IP={{ api_ip|default(machine_cidr|network_ip(2)) }}
export HOSTS=$(cat /root/iso_hosts | base64 -w0)
for role in bootstrap master worker; do
 echo Creating iso for $role
 if [ "$role" == "bootstrap" ] ; then
   cp $dir/$role.ign config.ign
 else
   export ROLE=$role
   envsubst < /root/ignition.template > config.ign
 fi
 # temporary set core password to core
 # cat preconfig.ign | jq '.passwd.users[0] += {"passwordHash": "$1$ADV1tN41$cK2P0jJl5BbJ9FW06/OgT."}' > config.ign
 python3 create_iso_ignition.py 
 $COREOSINSTALLER iso ignition embed -fi iso.ign rhcos-live.x86_64.iso
 cp rhcos-live.x86_64.iso /var/www/html/$cluster-$role.iso
done
