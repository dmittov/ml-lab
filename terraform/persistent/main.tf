provider "google" {
  project = var.project
  region  = var.region
}

data "google_client_config" "default" {}

resource "google_service_account" "default" {
  account_id   = "default-service-account-id"
  display_name = "Default Service Account"
}

resource "google_storage_bucket" "datasets" {
  name                        = var.dataset_bucket
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "tf-state" {
  name                        = var.state_bucket
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}
