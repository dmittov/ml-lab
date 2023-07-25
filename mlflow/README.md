gsutil -m rm -r gs://ml-lab-324709-postgres/mlflow

gsutil -m rm -r gs://ml-lab-324709-postgres/mlflow-backup
gsutil -m mv gs://ml-lab-324709-postgres/mlflow gs://ml-lab-324709-postgres/mlflow-backup
