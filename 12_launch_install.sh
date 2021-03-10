export HOME=/root
dir="/root/ocp"
cluster={{ cluster }}
plan={{ plan }}
pool={{ pool }}
{% for node in baremetal_masters %}
/root/bin/racadm.sh {{ cluster }} master {{ node['ipmi_address'] }} {{ node['ipmi_user'] | default(ipmi_user) }} {{ node['ipmi_password'] | default(ipmi_password) }}
{% endfor %}
{% for node in baremetal_workers %}
/root/bin/racadm.sh {{ cluster }} worker {{ node['ipmi_address'] }} {{ node['ipmi_user'] | default(ipmi_user) }} {{ node['ipmi_password'] | default(ipmi_password) }}
{% endfor %}
dnf -y copr enable karmab/kcli
dnf -y install kcli
mkdir -p /root/.kcli
echo """default:
 client: mycli
mycli:
 host: {{ config_host|default(baremetal_net|local_ip) }}
 user: {{ config_user|default('root') }}
""" > /root/.kcli/config.yml 
IP="$(hostname -I | cut -f1 -d" " | xargs)"
for role in bootstrap master worker ; do
  kcli delete image -y -p $pool $cluster-$role.iso
  kcli download image -u http://$IP:8080/$cluster-$role.iso -p $pool $cluster-$role.iso
done
kcli start plan $plan
openshift-install --dir $dir --log-level debug wait-for bootstrap-complete
[ -f /root/manifests/99-autorules.yaml ] && oc create -f /root/manifests/99-autorules.yaml
openshift-install --dir $dir --log-level debug wait-for install-complete
kcli stop vm $cluster-bootstrap
