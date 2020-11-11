#!/usr/bin/env bash

IP=$(hostname -I | cut -d' ' -f1)
export KUBECONFIG=/root/ocp/auth/kubeconfig
echo Ignition assets available:
echo http://$IP:8080/{{cluster }}-bootstrap.iso
echo http://$IP:8080/{{cluster }}-master.iso
echo http://$IP:8080/{{cluster }}-worker.iso
