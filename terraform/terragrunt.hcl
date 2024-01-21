generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket = "ml-lab-324709-tf-state"
    prefix = "terraform/${path_relative_to_include()}"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~>5.0"
        }

        # Use the latest versions
        kubernetes = {
            source = "hashicorp/kubernetes"
        }
        helm = {
            source = "hashicorp/helm"
        }
    }
}
provider "google" {
    project = "ml-lab-324709"
    region  = "europe-west1"
}
EOF
}
