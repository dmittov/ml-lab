terraform {
  backend "gcs" {
    # variables are not allowed in backend
    bucket = "ml-lab-324709-tf-state"
    prefix = "terraform/persistent"
  }
}
