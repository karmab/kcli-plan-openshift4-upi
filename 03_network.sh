yum -y install dnsmasq radvd haproxy
cp /root/radvd.conf /etc
cp /root/haproxy.cfg /etc/haproxy
systemctl enable --now dnsmasq
systemctl enable --now radvd
systemctl enable --now haproxy

