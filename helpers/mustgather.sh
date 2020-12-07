#!/usr/bin/env bash

export KUBECONFIG=/root/ocp/auth/kubeconfig
IP=$(hostname -I | cut -d' ' -f1)
REVERSE_NAME=$(dig -x $IP +short | sed 's/\.[^\.]*$//')
REGISTRY_NAME=${REVERSE_NAME:-$(hostname -f)}
REGISTRY=$REGISTRY_NAME:5000
oc adm must-gather --image=$REGISTRY/{{ disconnected_prefix }}:$(oc get clusterversion version -o jsonpath='{.status.desired.version}-must-gather') --dest-dir /tmp/mustgather
