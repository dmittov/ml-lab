# Deploy the Infrastructure

## Login

```bash
gcloud auth application-default login
```

## Persistent infra

```bash
$ cd persistent
$ terragrunt apply
...
Apply complete! Resources: N added, 0 changed, 0 destroyed.
```

## Kubernetes cluster

```bash
$ cd kubernetes
$ terragrunt apply
...
Apply complete! Resources: N added, 0 changed, 0 destroyed.
```

Destroy:

```bash
$ terragrunt destroy
...
Destroy complete! Resources: N destroyed.
```
