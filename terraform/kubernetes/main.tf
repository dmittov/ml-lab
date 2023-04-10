data "google_client_config" "default" {
}

data "terraform_remote_state" "persistent" {
  backend = "gcs"
  config = {
    bucket = "${data.google_client_config.default.project}-tf-state"
    prefix = "terraform/persistent"
  }
}

locals {
  cluster_zone = "${data.google_client_config.default.region}-${var.zone}"
  gke_roles    = ["roles/editor"]
  k8s_roles    = ["roles/storage.admin"]
  apis         = ["container.googleapis.com", "cloudbuild.googleapis.com"]
}

resource "google_project_service" "apis" {
  for_each                   = toset(local.apis)
  project                    = data.google_client_config.default.project
  service                    = each.value
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_service_account" "gke_account" {
  account_id   = "gke-service-accout"
  display_name = "Service Account for the GKE"
}

resource "google_service_account" "k8s_spark" {
  account_id   = "k8s-spark-service-accout"
  display_name = "Service Account for K8s/Spark"
}

resource "google_project_iam_member" "k8s_spark_roles" {
  for_each = toset(local.k8s_roles)
  project  = data.google_client_config.default.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.k8s_spark.email}"
}

resource "google_project_iam_member" "gke_account_roles" {
  for_each = toset(local.gke_roles)
  project  = data.google_client_config.default.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.gke_account.email}"
}

resource "google_container_cluster" "kube" {
  name = "dl-cluster"
  # Zonal cluster is good enough and GKE fee is $0
  location = local.cluster_zone

  depends_on = [
    google_service_account.gke_account,
    google_project_service.apis,
  ]

  enable_autopilot = true
  vertical_pod_autoscaling { enabled = true }
  release_channel {
    channel = "STABLE"
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.kube.endpoint
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(google_container_cluster.kube.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.kube.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.kube.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.kube.endpoint
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(google_container_cluster.kube.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.kube.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.kube.master_auth.0.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "spark_jobs" {
  metadata {
    name = "spark-jobs"
  }
}

resource "helm_release" "k8s-spark" {
  name             = "spark-operator"
  repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart            = "spark-operator"
  namespace        = "spark-operator"
  create_namespace = true
  set {
    name  = "sparkJobNamespace"
    value = kubernetes_namespace.spark_jobs.metadata[0].name
    type  = "string"
  }
}

resource "google_service_account_key" "k8s_spark" {
  service_account_id = google_service_account.k8s_spark.name
}

resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name      = "k8s-spark-secret"
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
