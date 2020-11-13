#!/bin/bash

WEBDIR="/var/www/html"
ROOTFS="http://$IP/rootfs.img"
MCP="worker"
IGNITION_FILE="http://$IP/$MCP.ign"
OUTPUT="$WEBDIR/$MCP-small.iso"
# KERNEL_ARGS="ip=192.168.122.211::192.168.122.1:255.255.255.0:biloute.karmalabs.com:ens3:on:8.8.8.8"
KERNELS_ARGS=""

BASE="/tmp/base.iso"
IP=$(hostname -I | cut -f1 -d" ")
if [ ! -f $WEBDIR/rootfs.img ]
then
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live-rootfs.x86_64.img  > $WEBDIR/rootfs.img
fi

# cp /root/ocp/worker.ign /var/www/html/worker.ign
curl -H "Accept: application/vnd.coreos.ignition+json; version=3.1.0" -Lk https://$API_IP:22623/config/$MCP > /var/www/html/$MCP.ign
# use jq or other tools here to tweak $MCP.ign, for static networking for instance

rm -rf /tmp/base.iso $OUTPUT /tmp/syslinux* /tmp/coreos ztp-iso-generator
yum -y install git mkisofs
git clone https://github.com/redhat-ztp/ztp-iso-generator.git
cd ztp-iso-generator/rhcos-iso
./generate_rhcos_iso.sh $BASE
./inject_config_files.sh $BASE $OUTPUT $IGNITION_FILE $ROOTFS "$KERNEL_ARGS"
