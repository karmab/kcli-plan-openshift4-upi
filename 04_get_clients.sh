#!/usr/bin/env bash

curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/bin/jq	
chmod u+x /usr/bin/jq

curl -k -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz > oc.tar.gz
tar zxf oc.tar.gz
rm -rf oc.tar.gz
mv oc /usr/bin
chmod +x /usr/bin/oc

curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl > /usr/bin/kubectl
chmod u+x /usr/bin/kubectl

curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/4.6.1/rhcos-live.x86_64.iso > /root/rhcos-live.x86_64.iso
curl -Lk https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux-4.6.1.tar.gz > openshift-install-linux-4.6.1.tar.gz
tar zxvf openshift-install-linux-4.6.1.tar.gz
rm -rf openshift-install-linux-4.6.1.tar.gz
mv openshift-install /usr/bin
chmod +x /usr/bin/openshift-install

oc completion bash >>/etc/bash_completion.d/oc_completion

echo """[racadm]
name=Racadm
baseurl=http://linux.dell.com/repo/hardware/dsu/os_dependent/RHEL8_64
enabled=1
gpgcheck=0""" > /etc/yum.repos.d/racadm.repo
dnf -y install openssl-devel srvadmin-idracadm7
