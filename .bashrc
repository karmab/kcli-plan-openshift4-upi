# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
export KUBECONFIG=/root/ocp/auth/kubeconfig
export PATH=/usr/local/bin:/root/bin:$PATH
alias coreos-installer='podman run --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release'
alias openshift-install-bootstrap='openshift-install --dir /root/ocp --log-level debug wait-for bootstrap-complete'
alias openshift-install-complete='openshift-install --dir /root/ocp --log-level debug wait-for install-complete'
