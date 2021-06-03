#!/usr/bin/env bash

export KUBECONFIG=/root/ocp/auth/kubeconfig
REGISTRY_NAME=$(hostname -f)
REGISTRY=$REGISTRY_NAME:5000
oc adm must-gather --image=$REGISTRY/{{ disconnected_prefix }}:$(oc get clusterversion version -o jsonpath='{.status.desired.version}-x86_64-must-gather') --dest-dir /tmp/mustgather
