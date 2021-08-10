provider "google" {
  project = var.project
  region  = var.region
}

data "terraform_remote_state" "persistent" {
  backend = "gcs"
  config = {
    bucket = "dmittov-tf-state"
    prefix = "terraform/persistent"
  }
}

data "google_client_config" "default" {
}

locals {
  cluster_zone = "${data.google_client_config.default.region}-${var.zone}"
}

resource "google_container_cluster" "kube" {
  name = "dl-cluster"
  # Zonal cluster is good enough and GKE fee is $0
  location = local.cluster_zone

  # GPUs/TPUs are not available for autopilot clusters
  enable_autopilot = false

  # Separately managed node pool is preferred, but it's not compatible
  # with no-autopilot
  # remove_default_node_pool = true
  initial_node_count = 1
  node_config {
    preemptible = true
    # cost-optimized instance: 2 shared vCPU (50%, up to 100% for short periods) 
    # medium: 4GB
    # small: 2GB
    # micro: 1GB
    machine_type = "e2-medium"

    service_account = data.terraform_remote_state.persistent.outputs.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

# additional node pool example
resource "google_container_node_pool" "additional_preemptible_nodes" {
  count = 0
  name       = "additional-node-pool"
  location   = local.cluster_zone
  cluster    = google_container_cluster.kube.name
  node_count = 1
  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = data.terraform_remote_state.persistent.outputs.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

}
