# Notes

## Add/Remove GKE clusters

```bash
gcloud container clusters get-credentials dl-cluster --zone europe-west1-b
```

```bash
kubectl config unset contexts.gke_deeplearning-321920_europe-west1-b_dl-cluster
kubectl config unset clusters.gke_deeplearning-321920_europe-west1-b_dl-cluster
```
