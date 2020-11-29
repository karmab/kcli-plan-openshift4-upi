#!/bin/bash
{%- set nics = [] -%}
{% if disable_nics is defined -%}
{%- for nic in disable_nics %}
{%- do nics.append("ip=" + nic + ":off") %}
{%- endfor -%}
{%- endif %}
#firstboot_args='console=tty0 rd.neednet=1 {{ nics | join(" ") }}'
firstboot_args='console=tty0 rd.neednet=1'
if [ -s /root/static.txt ] ; then
  NIC={{ provisioning_nic }}
  [ -d /sys/class/net/ens3 ] && NIC=ens3
  MAC="$(cat /sys/class/net/$NIC/address)"
  LINE=$(grep $MAC /root/static.txt)
  if [ "$LINE" != "" ] ; then
  HOSTNAME=$( echo $LINE | cut -d, -f2)
  IP=$( echo $LINE | cut -d, -f3)
  firstboot_args="$firstboot_args ip=$IP::{{ machine_cidr | network_ip(1, True) }}:64:$HOSTNAME.{{ domain }}:$NIC:none nameserver={{ machine_cidr | network_ip(1, True) }} {{ nics | join(" ") }}"
  fi
fi

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
