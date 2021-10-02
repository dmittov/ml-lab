# Deploy the Infrastructure

## Login

```bash
gcloud auth application-default login
```


## Persistent infra

```bash
$ cd persistent
$ terraform apply -var-file ../terraform.tfvars -compact-warnings
...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## Kubernetes cluster

```bash
$ cd kubernetes
$ terraform apply -var-file ../terraform.tfvars -compact-warnings
...
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Destroy:

```bash
$ terraform destroy -var-file ../terraform.tfvars -compact-warnings
...
Destroy complete! Resources: 1 destroyed.
```
