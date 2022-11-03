$namespaces = (
    "red",
    "orange",
    "yellow",
    "green",
    "blue",
    "indigo",
    "violet"
)

foreach ($namespace in $namespaces) {
    kubectl create ns $namespace
    kubectl apply -f ..\k8s\deploy+svc.yaml -n $namespace
}

# kubectl run alpine --image alpine -- sh -c 'apk add curl && while true; do for ns in red orange yellow green blue indigo violet; do curl hello-world.$ns && sleep 1; done; done'
