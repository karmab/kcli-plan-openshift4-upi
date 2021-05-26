setenforce 0
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
{% if baremetal_vips %}
PREFIX=$(ip a l  eth0 | grep inet | head -1 | awk '{print $2}' | cut -d/ -f2)
{% for vip in baremetal_vips %}
nmcli con mod "System eth0" +ipv4.addresses {{ vip }}/$PREFIX
{% endfor %}
nmcli conn up "System eth0"
{% endif %}

PREFIX={{ machine_cidr.split('/')[1] }}
{% if ':' in machine_cidr %}
nmcli con mod "System eth1" ipv6.addresses {{ installer_ip|default(machine_cidr|network_ip(1)) }}/$PREFIX ipv6.method manual
nmcli con mod "System eth1" +ipv6.addresses {{ api_ip|default(machine_cidr|network_ip(2)) }}/$PREFIX
nmcli con mod "System eth1" +ipv6.addresses {{ ingress_ip|default(machine_cidr|network_ip(3)) }}/$PREFIX
{% else %}
nmcli con mod "System eth1" ipv4.addresses {{ installer_ip|default(machine_cidr|network_ip(1)) }}/$PREFIX ipv4.method manual
nmcli con mod "System eth1" +ipv4.addresses {{ api_ip|default(machine_cidr|network_ip(2)) }}/$PREFIX
nmcli con mod "System eth1" +ipv4.addresses {{ ingress_ip|default(machine_cidr|network_ip(3)) }}/$PREFIX
{% endif %}
nmcli conn up "System eth1"

{% if dnsmasq %}
dnf -y install dnsmasq
cp /root/dnsmasq.conf /etc
cp /etc/resolv.conf /opt
chmod 755 /opt/resolv.conf
echo nameserver {{ machine_cidr|network_ip(1) }} > /etc/resolv.conf
echo search {{ cluster }}.{{ domain }} >> /etc/resolv.conf
chattr +i /etc/resolv.conf
systemctl enable --now dnsmasq
{% endif %}
{% if ':' in machine_cidr %}
dnf -y install radvd
cp /root/radvd.conf /etc
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.{{ installer_provisioning_nic }}.accept_ra=2
systemctl enable --now radvd
{% else %}
sysctl -w net.ipv4.conf.all.forwarding=1
{% endif %}
{% if haproxy %}
dnf -y install haproxy
cp /root/haproxy.cfg /etc/haproxy
sleep 20
systemctl enable --now haproxy
{% endif %}

{% if static_ips %}
cp /opt/hosts /root/static.txt
{% endif %}
