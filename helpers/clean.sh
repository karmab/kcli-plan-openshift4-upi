#!/usr/bin/env bash

CLUSTER={{ cluster }}
dir=/root/ocp
pool={{ pool }}
[ -d $dir ] && rm -rf $dir
rm -rf /var/www/html/$CLUSTER*

kcli stop vm {{ cluster }}-bootstrap
kcli delete disk {{ cluster }}-bootstrap_0.img -y
kcli create disk -s {{ disk_size }} -p $pool {{ cluster }}-bootstrap
{% if virtual_masters %}
{% for num in range(0, virtual_masters_number) %}
kcli stop vm {{ cluster }}-master-{{ num }}
kcli delete disk {{ cluster }}-master-{{ num }}_0.img -y
kcli create disk -s {{ disk_size }} -p $pool {{ cluster }}-master-{{ num }}
{% endfor %}
{% endif %}
{% if virtual_workers %}
{% for num in range(0, virtual_workers_number) %}
kcli stop vm {{ cluster }}-worker-{{ num }}
kcli delete disk {{ cluster }}-worker-{{ num }}_0.img -y
kcli create disk -s {{ disk_size }} -p $pool {{ cluster }}-worker-{{ num }}
{% endfor %}
{% endif %}
