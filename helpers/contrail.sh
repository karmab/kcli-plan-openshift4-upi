export TMP_DIR=/tmp
export INSTALL_DIR=/root/ocp
export CONTAINER_REGISTRY="hub.juniper.net/contrail-nightly"
export CONTRAIL_CONTAINER_TAG="R2011.L1.277"
export KUBECONFIG=$INSTALL_DIR/auth/kubeconfig
export DEPLOYER="openshift"
export KUBERNETES_CLUSTER_NAME="{{ cluster }}"
export KUBERNETES_CLUSTER_DOMAIN="{{ domain }}"
export CONTRAIL_REPLICAS=3

cd $TMP_DIR

yum -y install python3
git clone -b R2011 https://github.com/tungstenfabric/tf-openshift.git
./tf-openshift/scripts/apply_install_manifests.sh $INSTALL_DIR

git clone -b R2011 https://github.com/tungstenfabric/tf-operator.git
./tf-operator/contrib/render_manifests.sh

for i in $(ls ./tf-operator/deploy/crds/) ; do
  cp ./tf-operator/deploy/crds/$i $INSTALL_DIR/manifests/01_$i
done

for i in namespace service-account role cluster-role role-binding cluster-role-binding ; do
  cp ./tf-operator/deploy/kustomize/base/operator/$i.yaml $INSTALL_DIR/manifests/02-tf-operator-$i.yaml
done

oc kustomize ./tf-operator/deploy/kustomize/operator/templates/ | sed -n 'H; /---/h; ${g;p;}' > $INSTALL_DIR/manifests/02-tf-operator.yaml
oc kustomize ./tf-operator/deploy/kustomize/contrail/templates/ > $INSTALL_DIR/manifests/03-tf.yaml


for image in tf-operator contrail-vrouter-kernel-init contrail-provisioner contrail-nodemgr contrail-vrouter-agent contrail-vrouter-kernel-init contrail-kubernetes-cni-init contrail-node-init contrail-status contrail-tools contrail-external-zookeeper contrail-external-cassandra contrail-external-rabbitmq contrail-controller-config-api contrail-controller-config-schema contrail-controller-config-devicemgr contrail-controller-config-dnsmasq contrail-controller-config-svcmonitor contrail-analytics-api contrail-analytics-query-engine contrail-analytics-collector contrail-external-redis contrail-external-stunnel contrail-controller-control-control contrail-controller-control-dns contrail-kubernetes-kube-manager contrail-controller-control-named contrail-controller-control-control contrail-analytics-alarm-gen contrail-external-kafka contrail-analytics-snmp-collector contrail-analytics-snmp-topology contrail-controller-webui-job contrail-controller-webui-web; do /root/bin/sync_image.sh hub.juniper.net/contrail-nightly/$image:R2011.L1.277 ; done
REGISTRY=$(cat /root/version.txt | cut -d'/' -f1)
#cat << EOF >> /root/ocp/manifests/contrail_icsp.yaml
#apiVersion: operator.openshift.io/v1alpha1
#kind: ImageContentSourcePolicy
#metadata:
#  name: contrail-iscp
#spec:
#  repositoryDigestMirrors:
#  - mirrors:
#    - $REGISTRY/contrail-nightly
#    source: hub.juniper.net/contrail-nightly
#EOF

cat < EOF > /root/registries.conf
unqualified-search-registries = ["registry.access.redhat.com", "docker.io"]

[[registry]]
  prefix = ""
  location = "hub.juniper.net/contrail-nightly"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "$REGISTRY/contrail-nightly"

[[registry]]
  prefix = ""
  location = "quay.io/openshift-release-dev/ocp-release"
  mirror-by-digest-only = true

  [[registry.mirror]]
    location = "$REGISTRY/ocp4"

[[registry]]
  prefix = ""
  location = "quay.io/openshift-release-dev/ocp-v4.0-art-dev"
  mirror-by-digest-only = true

  [[registry.mirror]]
    location = "$REGISTRY/ocp4"
EOF
export REGISTRIES_DATA=$(cat /root/registries.conf | base64 -w0)
export ROLE=master
envsubst < /root/99-contrail-registries.sample.yaml > /root/manifests/99-contrail-registries-master.yaml
export ROLE=worker
envsubst < /root/99-contrail-registries.sample.yaml > /root/manifests/99-contrail-registries-worker.yaml
