#!/usr/bin/env bash

#set -euo pipefail

cd /root
export PATH=/root/bin:$PATH
export HOME=/root
export KUBECONFIG=/root/ocp/auth/kubeconfig
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$(cat /root/version.txt)
mkdir -p ocp/openshift
cp install-config.yaml ocp
openshift-install --dir ocp --log-level debug create manifests
ls manifests/*y*ml >/dev/null && cp manifests/*y*ml ocp/openshift
openshift-install --dir=ocp create ignition-configs
