IP=$(hostname -I | cut -d' ' -f1)
REGISTRY_NAME=$(hostname -f)
REGISTRY=$REGISTRY_NAME:5000
PULL_SECRET="/root/openshift_pull.json"
image=$1
skopeo copy docker://$image docker://$REGISTRY/$(echo $image | cut -d'/' -f 2- ) --all --authfile $PULL_SECRET
