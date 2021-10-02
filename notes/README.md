# Notes

## Add/Remove GKE clusters

```bash
gcloud container clusters get-credentials dl-cluster --zone europe-west1-b
```

```bash
kubectl config unset contexts.gke_ml-lab-324709_europe-west1-b_dl-cluster
kubectl config unset clusters.gke_ml-lab-324709_europe-west1-b_dl-cluster
```

## No rights to destroy the cluster

gcloud projects add-iam-policy-binding ml-lab-324709 \
    --member serviceAccount:670967409083@cloudservices.gserviceaccount.com \
    --role roles/editor
