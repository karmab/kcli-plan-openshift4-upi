export NM_DATA=$((cat << EOF
[main]
rc-manager=file
[connection]
ipv6.dhcp-duid=ll
ipv6.dhcp-iaid=mac
{% if disable_nics %}
[keyfile]
unmanaged-devices=interface-name:{{ disable_nics|join(';interface-name:') }}
{% endif %}
EOF
) | base64 -w0)
export ROLE=worker
envsubst < /root/99-nm.sample.yaml > /root/manifests/99-nm-worker.yaml
export ROLE=master
envsubst < /root/99-nm.sample.yaml > /root/manifests/99-nm-master.yaml
