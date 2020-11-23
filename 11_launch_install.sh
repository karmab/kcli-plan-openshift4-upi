cluster={{ cluster }}
pool={{ pool }}
{%- for node in baremetal_masters %}
/root/bin/racadm.sh {{ cluster }} master {{ node['ipmi_address'] }} {{ node['ipmi_user'] | default(ipmi_user) }} {{ node['ipmi_password'] | default(ipmi_password) }}
{%- endfor %}
{%- for node in baremetal_workers %}
/root/bin/racadm.sh {{ cluster }} worker {{ node['ipmi_address'] }} {{ node['ipmi_user'] | default(ipmi_user) }} {{ node['ipmi_password'] | default(ipmi_password) }}
{%- endfor %}
dnf -y copr enable karmab/kcli
dnf -y install kcli
mkdir -p /root/.kcli
echo """default:
 client: mycli
mycli:
 host: {{ config_host }}
 user: {{ config_user|default('root') }}
""" > /root/.kcli/config.yml 
IP="$(hostname -I | cut -f1 -d" " | xargs)"
for role in bootstrap master worker ; do
  kcli download image -u http://$IP:8080/$cluster-$role.iso -p $pool $cluster-$role.iso
done
kcli start plan {{ plan }}
