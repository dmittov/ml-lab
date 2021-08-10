terraform {
  backend "gcs" {
    bucket = "dmittov-tf-state"
    prefix = "terraform/kubernetes"
  }
}
