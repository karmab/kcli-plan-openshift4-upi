IP=$(hostname -I | cut -d' ' -f1)
REVERSE_NAME=$(dig -x $IP +short | sed 's/\.[^\.]*$//')
REGISTRY_NAME=${REVERSE_NAME:-$(hostname -f)}
REGISTRY=$REGISTRY_NAME:5000
PULL_SECRET="/root/openshift_pull.json"
skopeo copy docker://$image docker://$REGISTRY/$(echo $image | sed 's@quay.io/@@') --all --authfile $PULL_SECRET
