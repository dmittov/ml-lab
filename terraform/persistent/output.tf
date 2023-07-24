output "service_account" {
  value = google_service_account.default
}

output "postgres_bucket" {
  value = google_storage_bucket.postgres.name
}

output "mlflow_bucket" {
  value = google_storage_bucket.mlflow.name
}
