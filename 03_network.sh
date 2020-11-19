setenforce 0
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
{%- if baremetal_vips %}
PREFIX=$(ip a l  eth0 | grep inet | head -1 | awk '{print $2}' | cut -d/ -f2)
{%- for vip in baremetal_vips %}
nmcli con mod "System eth0" +ipv4.addresses {{ vip }}/$PREFIX
{%- endfor %}
nmcli conn up "System eth0"
{%- endif %}
dnf -y install dnsmasq radvd haproxy
{% if dnsmasq %}
cp /root/dnsmasq.conf /etc
cp /etc/resolv.conf /opt
chmod 755 /opt/resolv.conf
echo nameserver $(hostname -I | cut -d' ' -f1) > /etc/resolv.conf
echo search {{ cluster }}.{{ domain }} >> /etc/resolv.conf
chattr +i /etc/resolv.conf
systemctl enable --now dnsmasq
{% endif %}
{% if radvd %}
cp /root/radvd.conf /etc
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.eth1.accept_ra=2
systemctl enable --now radvd
{% endif %}
{% if haproxy %}
cp /root/haproxy.cfg /etc/haproxy
sleep 20
systemctl enable --now haproxy
{% endif %}
