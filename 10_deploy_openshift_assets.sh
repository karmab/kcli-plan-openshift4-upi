#!/usr/bin/env bash

#set -euo pipefail

dir="/root/ocp"
cd /root
export PATH=/root/bin:$PATH
export HOME=/root
export KUBECONFIG=$dir/auth/kubeconfig
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$(cat /root/version.txt)
mkdir -p $dir/openshift
cp install-config.yaml $dir
openshift-install --dir $dir --log-level debug create manifests
ls manifests/*y*ml >/dev/null && cp manifests/*y*ml $dir/openshift
{% if network_type == 'Contrail' %}
bash /root/bin/contrail.sh
{% endif %}
openshift-install --dir $dir --log-level debug create ignition-configs
