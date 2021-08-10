terraform {
  backend "gcs" {
    # variables are not allowed in backend
    bucket = "dmittov-tf-state"
    prefix = "terraform/persistent"
  }
}
