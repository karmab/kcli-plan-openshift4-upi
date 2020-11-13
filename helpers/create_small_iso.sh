#!/bin/bash

IP={{ installer_ip }}
echo $IP | grep ':' && IP=[$IP]
PORT=8080
API_ENDPOINT="api.{{ cluster }}.{{ domain }}"
WEBDIR="/var/www/html"
ROOTFS="http://$IP:$PORT/rootfs.img"
MCP="worker"
IGNITION_FILE="http://$IP:$PORT/$MCP.ign"
OUTPUT="$WEBDIR/{{ cluster }}-$MCP-small.iso"
# KERNEL_ARGS="ip=192.168.122.211::192.168.122.1:255.255.255.0:biloute.karmalabs.com:ens3:on:8.8.8.8"
EXTRA_ARGS=""

yum -y install git mkisofs
BASE="/tmp/base.iso"
if [ ! -f $WEBDIR/rootfs.img ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live-rootfs.x86_64.img  > $WEBDIR/rootfs.img
fi

# cp /root/ocp/worker.ign /var/www/html/worker.ign
curl -H "Accept: application/vnd.coreos.ignition+json; version=3.1.0" -Lk https://$API_ENDPOINT:22623/config/$MCP > config.ign
# use jq or other tools here if tweaking $MCP.ign is needed (for static networking for instance) and move result to web dir
mv config.ign $WEBDIR/$MCP.ign

rm -rf /tmp/base.iso $OUTPUT /tmp/syslinux* /tmp/coreos ztp-iso-generator
git clone https://github.com/redhat-ztp/ztp-iso-generator.git
cd ztp-iso-generator/rhcos-iso
./generate_rhcos_iso.sh $BASE
./inject_config_files.sh $BASE $OUTPUT $IGNITION_FILE $ROOTFS "$EXTRA_ARGS"
