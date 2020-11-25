bash /root/01_patch_installconfig.sh
bash /root/02_packages.sh
bash /root/03_network.sh
/root/04_get_clients.sh
{% if build %}
bash /root/bin/build.sh
{% endif %}
{% if disconnected %}
/root/05_disconnected.sh
{% endif %}
{% if olm %}
/root/06_olm.sh
{% endif %}
{% if nbde %}
/root/07_nbde.sh
{% endif %}
{% if ntp %}
/root/08_ntp.sh
{% endif %}

bash /root/09_nm.sh
export KUBECONFIG=/root/ocp/auth/kubeconfig
bash /root/10_deploy_openshift_assets.sh
{% if small_iso %}
bash /root/11_create_small_isos.sh
{% else %}
bash /root/11_create_big_isos.sh
{% endif %}

{% if deploy %}
bash /root/12_launch_install.sh
{% endif %}
