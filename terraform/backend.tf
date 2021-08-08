terraform {
  backend "gcs" {
    # variables are not allowed in backend
    bucket = "dmittov-tf-state"
    prefix = "terraform/state"
  }
}

data "terraform_remote_state" "main-state" {
  backend = "gcs"
  config = {
    bucket = google_storage_bucket.tf-state.name
    prefix = "main"
  }
}
