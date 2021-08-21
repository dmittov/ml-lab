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

resource "google_service_account" "k8s_spark" {
  account_id   = "k8s-spark-service-accout"
  display_name = "Service Account for K8s/Spark"
}

resource "google_project_iam_binding" "k8s_spark" {
    role    = "roles/storage.admin"
    members = [
      "serviceAccount:${google_service_account.k8s_spark.email}"
    ]
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
  count = 1
  name       = "additional-node-pool"
  location   = local.cluster_zone
  cluster    = google_container_cluster.kube.name
  node_count = 2
  node_config {
    preemptible  = true
    machine_type = "n2d-standard-4"

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

provider kubernetes {
    host                   = "${google_container_cluster.kube.endpoint}"
    token                  = "${data.google_client_config.default.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.kube.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.kube.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.kube.master_auth.0.cluster_ca_certificate)}"
}

provider "helm" {
  kubernetes {
    host                   = "${google_container_cluster.kube.endpoint}"
    token                  = "${data.google_client_config.default.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.kube.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.kube.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.kube.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "kubernetes_namespace" "spark_jobs" {
  metadata {
    name = "spark-jobs"
  }
}

resource "helm_release" "k8s-spark" {
  name       = "spark-operator"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart      = "spark-operator"
  namespace  = "spark-operator"
  create_namespace = true
  set {
    name = "sparkJobNamespace"
    value = kubernetes_namespace.spark_jobs.metadata[0].name
    type = "string"
  }
}

resource "google_service_account_key" "k8s_spark" {
  service_account_id = google_service_account.k8s_spark.name
}

resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name = "k8s-spark-secret"
    namespace = "spark-jobs"
    annotations = {
      "kubernetes.io/service-account.name" = google_service_account_key.k8s_spark.name
    }
  }
  data = {
    "key.json" = base64decode(google_service_account_key.k8s_spark.private_key)
  }
  type = "kubernetes.io/service-account-token"
}
