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

curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live.x86_64.iso > /root/rhcos-live.x86_64.iso
{% if openshift_image != None %}
export PULL_SECRET="/root/openshift_pull.json"
export OPENSHIFT_RELEASE_IMAGE="{{ openshift_image }}"
oc adm release extract --registry-config $PULL_SECRET --command=oc --to /tmp $OPENSHIFT_RELEASE_IMAGE
mv /tmp/oc /usr/bin
oc adm release extract --registry-config $PULL_SECRET --command=openshift-install --to /usr/bin $OPENSHIFT_RELEASE_IMAGE
{% else %}
curl -Lk https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux.tar.gz > openshift-install-linux.tar.gz
tar zxvf openshift-install-linux.tar.gz
rm -rf openshift-install-linux.tar.gz
mv openshift-install /usr/bin
{% endif %}
chmod +x /usr/bin/openshift-install

oc completion bash >>/etc/bash_completion.d/oc_completion

echo """[racadm]
name=Racadm
baseurl=http://linux.dell.com/repo/hardware/dsu/os_dependent/RHEL8_64
enabled=1
gpgcheck=0""" > /etc/yum.repos.d/racadm.repo
dnf -y install openssl-devel srvadmin-idracadm7
