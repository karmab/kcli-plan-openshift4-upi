export REGISTRY="$(hostname -f):5000"
sync_image.sh quay.io/karmab/autolabeller
sync_image.sh quay.io/karmab/autosigner
envsubst < /root/99-autorules.yaml.sample > /root/manifests/99-autorules.yaml
