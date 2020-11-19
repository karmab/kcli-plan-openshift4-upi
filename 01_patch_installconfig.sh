{% if not disconnected -%}
PULLSECRET=$(cat /root/openshift_pull.json | tr -d [:space:])
echo -e "pullSecret: |\n  $PULLSECRET" >> /root/install-config.yaml
{%- endif %}
ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
SSHKEY=$(cat /root/.ssh/id_rsa.pub)
echo -e "sshKey: |\n  $SSHKEY" >> /root/install-config.yaml
echo -e "Host=*\nUser=core\nStrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" > /root/.ssh/config
