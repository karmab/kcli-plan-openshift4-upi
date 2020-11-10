bash /root/01_patch_installconfig.sh
bash /root/02_packages.sh
bash /root/03_network.sh
/root/04_get_clients.sh
/root/05_disconnected.sh
{% if nbde %}
/root/06_nbde.sh
{% endif %}
{% if ntp %}
/root/07_ntp.sh
{% endif %}

export KUBECONFIG=/root/ocp/auth/kubeconfig
bash /root/08_deploy_openshift.sh
bash /root/09_create_isos.sh
