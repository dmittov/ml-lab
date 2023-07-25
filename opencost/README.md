# Install

The helm chart requires an API key, looks like there is no way to use a ServiceAccount yet.

```bash
$ helm repo add opencost https://opencost.github.io/opencost-helm-chart

$ helm install \
    --create-namespace \
    --namespace opencost \
    -f values.yaml \
    opencost \
    opencost/opencost
```
