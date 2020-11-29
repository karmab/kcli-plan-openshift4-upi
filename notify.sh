#!/usr/bin/env bash

export KUBECONFIG=/root/ocp/auth/kubeconfig
{% if deploy -%}
oc get clusterversion
oc get node
{%- else -%}
IP=$(hostname -I | cut -d' ' -f1)
echo Ignition isos available at:
echo http://$IP:8080/{{cluster }}-bootstrap.iso
echo http://$IP:8080/{{cluster }}-master.iso
echo http://$IP:8080/{{cluster }}-worker.iso
{%- endif -%}
