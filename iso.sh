#!/bin/bash
firstboot_args='console=tty0 rd.neednet=1'
#network_args='ip=[2620:52:0:1302::41]::[2620:52:0:1302::1]:64:jhendrix.fender.com:ens3:none nameserver=[2620:52:0:1302::1]'
firstboot_args="$firstboot_args $network_args"

for vg in $(vgs -o name --noheadings) ; do vgremove -y $vg ; done
for pv in $(pvs -o name --noheadings) ; do pvremove -y $pv ; done
if [ -b /dev/vda ]; then
  install_device='/dev/vda'
elif [ -b /dev/sda ] && [ "$(lsblk /dev/sda)" != "" ] ; then
  install_device='/dev/sda'
elif [ -b /dev/sdb ] && [ "$(lsblk /dev/sdb)" != "" ] ; then
  install_device='/dev/sdb'
elif [ -b /dev/sdc ] && [ "$(lsblk /dev/sdc)" != "" ] ; then
  install_device='/dev/sdc'
elif [ -b /dev/sdd ] && [ "$(lsblk /dev/sdd)" != "" ] ; then
  install_device='/dev/sdd'
elif [ -b /dev/nvme0 ]; then
  install_device='/dev/nvme0'
else
  echo "Can't find appropriate device to install to"
  exit 1
fi

cmd="coreos-installer install --firstboot-args=\"${firstboot_args}\" --ignition=/root/config.ign ${install_device}"
bash -c "$cmd"
if [ "$?" == "0" ] ; then
  echo "Install Succeeded!"
  reboot
else
  echo "Install Failed!"
  exit 1
fi
