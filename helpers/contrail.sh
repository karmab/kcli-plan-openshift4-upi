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
