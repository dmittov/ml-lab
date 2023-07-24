data "google_client_config" "default" {
}

data "terraform_remote_state" "persistent" {
  backend = "gcs"
  config = {
    bucket = "${data.google_client_config.default.project}-tf-state"
    prefix = "terraform/persistent"
  }
}
