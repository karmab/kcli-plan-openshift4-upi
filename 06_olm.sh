#!/bin/bash
# Variables to set, suit to your installation
cd /root
export OCP_RELEASE="4.6"
export OCP_PULLSECRET_AUTHFILE='/root/openshift_pull.json'
IP=$(hostname -I | cut -d' ' -f1)
REVERSE_NAME=$(dig -x $IP +short | sed 's/\.[^\.]*$//')
REGISTRY_NAME=${REVERSE_NAME:-$(hostname -f)}
export LOCAL_REGISTRY=$REGISTRY_NAME:5000
export LOCAL_REGISTRY_INDEX_TAG=olm-index/redhat-operator-index:v$OCP_RELEASE
export LOCAL_REGISTRY_IMAGE_TAG=olm

# Login registries
podman login -u '{{ disconnected_user }}' -p '{{ disconnected_password }}' $LOCAL_REGISTRY
#podman login registry.redhat.io --authfile /root/openshift_pull.json
REDHAT_CREDS=$(cat /root/openshift_pull.json | jq .auths.\"registry.redhat.io\".auth -r | base64 -d)
RHN_USER=$(echo $REDHAT_CREDS | cut -d: -f1)
RHN_PASSWORD=$(echo $REDHAT_CREDS | cut -d: -f2)
podman login -u "$RHN_USER" -p "$RHN_PASSWORD" registry.redhat.io

which opm >/dev/null 2>&1
if [ "$?" != "0" ] ; then
export REPO="operator-framework/operator-registry"
export VERSION=$(curl -s https://api.github.com/repos/$REPO/releases | grep tag_name | grep -v -- '-rc' | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
echo "Using Opm Version $VERSION"
curl -Lk https://github.com/operator-framework/operator-registry/releases/download/$VERSION/linux-amd64-opm > /usr/bin/opm
chmod u+x /usr/bin/opm
fi

# Set these values to true for the catalog and miror to be created
export RH_OP='true'
export RH_OP_INDEX="registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE}"
export CERT_OP_INDEX="registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE}"
export COMM_OP_INDEX="registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE}"
export MARKETPLACE_OP_INDEX="registry.redhat.io/redhat-marketplace-index:v${OCP_RELEASE}"
#export RH_OP_PACKAGES='local-storage-operator,performance-addon-operator,ptp-operator,sriov-network-operator'
export RH_OP_PACKAGES='{{ olm_operators|join(",") }}'

opm index prune --from-index $RH_OP_INDEX --packages $RH_OP_PACKAGES --tag $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG
podman push $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG --authfile $OCP_PULLSECRET_AUTHFILE
oc adm catalog mirror $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG $LOCAL_REGISTRY/$LOCAL_REGISTRY_IMAGE_TAG --registry-config=$OCP_PULLSECRET_AUTHFILE

echo "apiVersion: operators.coreos.com/v1alpha1" > redhat-operator-index-manifests/catalogsource.yaml
echo "kind: CatalogSource" >> redhat-operator-index-manifests/catalogsource.yaml
echo "metadata:" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  name: my-operator-catalog" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  namespace: openshift-marketplace" >> redhat-operator-index-manifests/catalogsource.yaml
echo "spec:" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  sourceType: grpc" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  image: $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  displayName: Temp Lab" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  publisher: templab" >> redhat-operator-index-manifests/catalogsource.yaml
echo "  updateStrategy:" >> redhat-operator-index-manifests/catalogsource.yaml
echo "    registryPoll:" >> redhat-operator-index-manifests/catalogsource.yaml
echo "      interval: 30m" >> redhat-operator-index-manifests/catalogsource.yaml

echo ""
echo "To apply the Red Hat Operators catalog mirror configuration to your cluster, do the following:"
echo "oc apply -f ./redhat-operator-index-manifests/imageContentSourcePolicy.yaml"  
echo "oc apply -f ./redhat-operator-index-manifests/catalogsource.yaml"  

echo 1
cp /root/redhat-operator-index-manifests/imageContentSourcePolicy.yaml /root/manifests  
cp /root/redhat-operator-index-manifests/catalogsource.yaml /root/manifests  
