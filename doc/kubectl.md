gcloud container clusters get-credentials --zone europe-west1-b dl-cluster

ctx=$(kubectl config current-context)
kubectl config delete-context $ctx 
kubectl config delete-cluster $ctx


gcloud auth login
gcloud container clusters get-credentials --zone europe-west1-b dl-cluster

