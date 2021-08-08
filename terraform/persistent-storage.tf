data "google_client_config" "default" {}

resource "google_storage_bucket" "datasets" {
  name                        = "dmittov-datasets"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "tf-state" {
  name                        = "dmittov-tf-state"
  location                    = data.google_client_config.default.region
  project                     = data.google_client_config.default.project
  force_destroy               = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}
