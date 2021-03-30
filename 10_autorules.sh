export REGISTRY="$(hostname -f):5000"
export PATH=/root/bin:$PATH
sync_image.sh quay.io/karmab/autolabeller
sync_image.sh quay.io/karmab/autosigner
cp /root/{99-autorules-namespace.yaml,99-autorules-configmap.yaml,99-autorules-clusterrolebinding.yaml} /root/manifests
envsubst < /root/99-autorules-deployment.yaml > /root/manifests/99-autorules-deployment.yaml
