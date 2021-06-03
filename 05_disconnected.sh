export PATH=/root/bin:$PATH
dnf -y install httpd httpd-tools jq bind-utils skopeo
{% if not 'rhel' in image %}
dnf -y module disable container-tools
dnf -y install 'dnf-command(copr)'
dnf -y copr enable rhcontainerbot/container-selinux
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
{% endif %}
dnf -y install podman
REGISTRY_NAME=$(hostname -f)
echo $REGISTRY_NAME:5000 > /root/url.txt
REGISTRY_USER={{ disconnected_user if disconnected_user != None else 'dummy' }}
REGISTRY_PASSWORD={{ disconnected_password if disconnected_password != None else 'dummy' }}
mkdir -p /opt/registry/{auth,certs,data,conf}
cat <<EOF | sudo tee /opt/registry/conf/config.yml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
compatibility:
  schema1:
    enabled: true
EOF
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /opt/registry/certs/domain.key -x509 -days 365 -out /opt/registry/certs/domain.crt -subj "/C=US/ST=Madrid/L=San Bernardo/O=Karmalabs/OU=Guitar/CN=$REGISTRY_NAME" -addext "subjectAltName=DNS:$REGISTRY_NAME"
cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
htpasswd -bBc /opt/registry/auth/htpasswd $REGISTRY_USER $REGISTRY_PASSWORD
podman create --name registry --net host --security-opt label=disable -v /opt/registry/data:/var/lib/registry:z -v /opt/registry/auth:/auth:z -v /opt/registry/conf/config.yml:/etc/docker/registry/config.yml -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /opt/registry/certs:/certs:z -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key {{ disconnected_registry_image }}
podman start registry
{% if openshift_image != None %}
export UPSTREAM_REGISTRY={{ openshift_image.split('/')[0] }}
export UPSTREAM_REPOSITORY={{ openshift_image.split('/')[1] }}
export BRANCH={{ openshift_image.split('/')[2].split(':')[0] }}
export RELEASE_NAME=$UPSTREAM_REPOSITORY/$BRANCH
export OCP_RELEASE={{ openshift_image.split(':')[1] }}
export FINAL_SOURCE=$UPSTREAM_REGISTRY/$RELEASE_NAME
{% else %}
export UPSTREAM_REGISTRY={{ disconnected_origin }}
export UPSTREAM_REPOSITORY=openshift-release-dev
export BRANCH=ocp-release
export RELEASE_NAME=$UPSTREAM_REPOSITORY/$BRANCH
export OCP_RELEASE={{ tag }}-x86_64
export FINAL_SOURCE={{ disconnected_origin }}/ocp-release
{% endif %}
export LOCAL_REGISTRY=$REGISTRY_NAME:5000
export PULL_SECRET=/root/openshift_pull.json
KEY=$( echo -n $REGISTRY_USER:$REGISTRY_PASSWORD | base64)
jq ".auths += {\"$REGISTRY_NAME:5000\": {\"auth\": \"$KEY\",\"email\": \"jhendrix@karmalabs.com\"}}" < $PULL_SECRET > /root/temp.json
cat /root/temp.json | tr -d [:space:] > $PULL_SECRET
oc adm release mirror -a $PULL_SECRET --from=${UPSTREAM_REGISTRY}/${RELEASE_NAME}:${OCP_RELEASE} --to-release-image=${LOCAL_REGISTRY}/{{ disconnected_prefix }}/release:${OCP_RELEASE} --to=${LOCAL_REGISTRY}/{{ disconnected_prefix }}
echo "{\"auths\": {\"$REGISTRY_NAME:5000\": {\"auth\": \"$KEY\", \"email\": \"jhendrix@karmalabs.com\"}}}" > /root/temp.json
OPENSHIFT_VERSION=$( grep cluster-openshift-apiserver-operator /var/log/cloud-init-output.log  | head -1 | awk '{print $NF}' | sed 's/-cluster-openshift-apiserver-operator//')

echo $REGISTRY_NAME:5000/{{ disconnected_prefix }}/release:$OCP_RELEASE > /root/version.txt
cat << EOF >> /root/install-config.yaml
imageContentSources:
- mirrors:
  - $LOCAL_REGISTRY/{{ disconnected_prefix }}
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
- mirrors:
  - $LOCAL_REGISTRY/{{ disconnected_prefix }}
  source: $FINAL_SOURCE
EOF

echo "additionalTrustBundle: |" >> /root/install-config.yaml
sed -e 's/^/  /' /opt/registry/certs/domain.crt >>  /root/install-config.yaml

PULLSECRET=$(cat /root/temp.json | tr -d [:space:])
echo -e "pullSecret: |\n  $PULLSECRET" >> /root/install-config.yaml

{% for image in extra_images %}
/root/bin/sync_image.sh {{ image }}
{% endfor %}
