helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install \
    --create-namespace \
    --namespace prometheus \
    -f values.yaml \
    prometheus \
    prometheus-community/kube-prometheus-stack
