data "google_client_config" "default" {}

resource "google_service_account" "default" {
  account_id   = "default-service-account-id"
  display_name = "Default Service Account"
}

resource "google_storage_bucket" "datasets" {
  name                        = "${data.google_client_config.default.project}-datasets"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "postgres" {
  name                        = "${data.google_client_config.default.project}-postgres"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "mlflow" {
  name                        = "${data.google_client_config.default.project}-mlflow"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "tf-state" {
  name                        = "${data.google_client_config.default.project}-tf-state"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "spark" {
  name                        = "${data.google_client_config.default.project}-spark"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_artifact_registry_repository" "docker-main" {
  location      = data.google_client_config.default.region
  repository_id = "main"
  description   = "main docker repository"
  format        = "DOCKER"
}
