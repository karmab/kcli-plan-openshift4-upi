
# nmcli con mod baremetal.153 +ipv6.addresses 2620:52:0:1303::3/64
# nmcli con mod baremetal.153 +ipv6.addresses 2620:52:0:1303::3/64
yum -y install dnsmasq radvd haproxy
cp /root/dnsmasq.conf /etc
# touch /opt/leases
# chmod 777 /opt/leases
cp /etc/resolv.conf /opt
chmod 755 /opt/resolv.conf
echo nameserver $(hostname -I | cut -d' ' -f1) > /etc/resolv.conf
chattr +i /etc/resolv.conf
cp /root/radvd.conf /etc
cp /root/haproxy.cfg /etc/haproxy
systemctl enable --now dnsmasq
systemctl enable --now radvd
sleep 30
systemctl enable --now haproxy

