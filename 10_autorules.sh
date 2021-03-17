export REGISTRY="$(hostname -f):5000"
export PATH=/root/bin:$PATH
sync_image.sh quay.io/karmab/autolabeller
sync_image.sh quay.io/karmab/autosigner
envsubst < /root/99-autorules.yaml.sample > /root/99-autorules.yaml
