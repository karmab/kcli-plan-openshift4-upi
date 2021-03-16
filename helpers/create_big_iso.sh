API_IP="api.upi.karmalabs.com"
MCP="worker"
curl -H "Accept: application/vnd.coreos.ignition+json; version=3.1.0" -Lk https://$API_IP:22623/config/$MCP > preconfig.ign
cp preconfig.ign config.ign
# uncomment to inject a password for core user
#cat preconfig.ign | jq '.passwd.users[0] += {"passwordHash": "$1$f9F1p5ap$VIFGF2QHttm6xPeGMh/YA/"}' > config.ign
python3 create_iso_ignition.py || exit 1
[ -f rhcos-live.x86_64.iso ] || curl https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live.x86_64.iso > rhcos-live.x86_64.iso
sudo podman run --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release iso ignition embed -fi iso.ign rhcos-live.x86_64.iso
