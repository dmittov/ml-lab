resource "google_pubsub_schema" "house_features" {
  name       = "house_features"
  type       = "PROTOCOL_BUFFER"
  definition = file("${path.module}/../../vertex/proto/house_features.proto")
}

resource "google_pubsub_topic" "house_pricing" {
  name       = "house_prices"
  depends_on = [google_pubsub_schema.house_features]

  schema_settings {
    schema   = "projects/${google_bigquery_table.house_features.project}/schemas/house_features"
    encoding = "BINARY"
  }
}

resource "google_pubsub_subscription" "house_pricing_bigquery" {
  name  = "house_prices_bigquery"
  topic = google_pubsub_topic.house_pricing.name

  bigquery_config {
    table               = "${google_bigquery_table.house_features.project}.${google_bigquery_table.house_features.dataset_id}.${google_bigquery_table.house_features.table_id}"
    use_topic_schema    = true
    drop_unknown_fields = true
    write_metadata      = true
  }

  depends_on = [
    google_project_iam_member.viewer, google_project_iam_member.editor
  ]
}
