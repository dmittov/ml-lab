terraform {
  backend "gcs" {
    bucket = "ml-lab-324709-tf-state"
    prefix = "terraform/kubernetes"
  }
}
