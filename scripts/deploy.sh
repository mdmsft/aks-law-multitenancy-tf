#!/usr/bin/env sh

# set -e -o pipefail

for ns in red orange yellow green blue indigo violet; do
    kubectl create ns $ns
    kubectl apply -f ./k8s/deploy+svc.yaml -n $ns
done

kubectl run alpine --image alpine -- sh -c 'apk add curl && while true; do for ns in red orange yellow green blue indigo violet; do curl hello-world.$ns && sleep 1; done; done'
