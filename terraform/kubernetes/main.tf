locals {
  cluster_zone = "${data.google_client_config.default.region}-${var.zone}"
  gke_roles    = ["roles/editor", "roles/artifactregistry.reader"]
  k8s_roles    = ["roles/storage.admin"]
  apis         = [
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudbilling.googleapis.com",
    "apikeys.googleapis.com",
  ]
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

resource "google_service_account" "pg" {
  account_id   = "postgres-backup"
  display_name = "Postgres Cloud Backup"
}

resource "google_service_account" "mlflow" {
  account_id   = "mlflow"
  display_name = "MLflow"
}

resource "google_service_account" "opencost" {
  account_id   = "opencost"
  display_name = "Service Account to access billing information"
}

resource "google_storage_bucket_iam_member" "postgres_admin" {
  bucket = data.terraform_remote_state.persistent.outputs.postgres_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.pg.email}"
}

resource "google_storage_bucket_iam_member" "mlflow" {
  bucket = data.terraform_remote_state.persistent.outputs.mlflow_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.mlflow.email}"
}

resource "google_billing_account_iam_member" "opencost" {
  billing_account_id = "01E73B-E3CB37-2961B2"
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${google_service_account.opencost.email}"
}


resource "google_container_cluster" "kube" {
  name = "dl-cluster"
  location = data.google_client_config.default.region

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.gke_account.email
    }
  }

  depends_on = [
    google_service_account.gke_account,
    google_project_service.apis,
  ]

  enable_autopilot = true
  vertical_pod_autoscaling {
    enabled = true
  }
  ip_allocation_policy {
  }
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
  host                   = "https://${google_container_cluster.kube.endpoint}"
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

resource "kubernetes_namespace" "pg" {
  metadata {
    name = "postgres"
  }
}

resource "google_service_account_iam_binding" "pg" {
  service_account_id = google_service_account.pg.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[mlflow/pg-mlflow]",
  ]
  depends_on = [
    google_container_cluster.kube,
    google_service_account.pg
  ]
}

resource "google_service_account_iam_binding" "mlflow" {
  service_account_id = google_service_account.mlflow.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[mlflow/mlflow]",
  ]
  depends_on = [
    google_container_cluster.kube,
    google_service_account.mlflow
  ]
}

resource "helm_release" "postgres_operator" {
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  namespace        = "cnpg"
  create_namespace = true
}


# resource "kubernetes_namespace" "spark_jobs" {
#   metadata {
#     name = "spark-jobs"
#   }
# }

# resource "helm_release" "k8s-spark" {
#   name             = "operator"
#   repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
#   chart            = "spark-operator"
#   namespace        = "spark"
#   create_namespace = true
#   set {
#     name  = "sparkJobNamespace"
#     value = kubernetes_namespace.spark_jobs.metadata[0].name
#     type  = "string"
#   }
# }

# resource "helm_release" "kafka_operator" {
#   name             = "operator"
#   repository       = "https://strimzi.io/charts"
#   chart            = "strimzi-kafka-operator"
#   namespace        = "kafka"
#   create_namespace = true
# }


# resource "google_service_account_key" "k8s_spark" {
#   service_account_id = google_service_account.k8s_spark.name
# }

# resource "kubernetes_secret" "google-application-credentials" {
#   metadata {
#     name      = "k8s-spark-secret"
#     namespace = "spark-jobs"
#     annotations = {
#       "kubernetes.io/service-account.name" = google_service_account_key.k8s_spark.name
#     }
#   }
#   data = {
#     "key.json" = base64decode(google_service_account_key.k8s_spark.private_key)
#   }
#   type = "kubernetes.io/service-account-token"
  
#   timeouts {
#     create = "10m"
#   }
# }
