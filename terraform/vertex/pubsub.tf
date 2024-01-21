resource "google_pubsub_schema" "house_area" {
  name       = "house_area"
  type       = "PROTOCOL_BUFFER"
  definition = file("${path.module}/../../vertex/proto/house_area.proto")
}

resource "google_pubsub_schema" "house_prices" {
  name       = "house_prices"
  type       = "PROTOCOL_BUFFER"
  definition = file("${path.module}/../../vertex/proto/house_prices.proto")
}


resource "google_pubsub_topic" "house_area" {
  name       = "house_area"
  depends_on = [google_pubsub_schema.house_area]

  schema_settings {
    schema   = "projects/${google_bigquery_table.house_area.project}/schemas/house_area"
    encoding = "BINARY"
  }
}

resource "google_pubsub_topic" "house_prices" {
  name       = "house_prices"
  depends_on = [google_pubsub_schema.house_prices]

  schema_settings {
    schema   = "projects/${google_bigquery_table.house_prices.project}/schemas/house_prices"
    encoding = "BINARY"
  }
}

resource "google_pubsub_subscription" "house_area_bigquery" {
  name  = "house_features_bigquery"
  topic = google_pubsub_topic.house_area.name

  bigquery_config {
    table               = "${google_bigquery_table.house_area.project}.${google_bigquery_table.house_area.dataset_id}.${google_bigquery_table.house_area.table_id}"
    use_topic_schema    = true
    drop_unknown_fields = true
    write_metadata      = true
  }

  depends_on = [
    google_project_iam_member.viewer, google_project_iam_member.editor
  ]
}

resource "google_pubsub_subscription" "house_prices_bigquery" {
  name  = "house_prices_bigquery"
  topic = google_pubsub_topic.house_prices.name

  bigquery_config {
    table               = "${google_bigquery_table.house_prices.project}.${google_bigquery_table.house_prices.dataset_id}.${google_bigquery_table.house_prices.table_id}"
    use_topic_schema    = true
    drop_unknown_fields = true
    write_metadata      = true
  }

  depends_on = [
    google_project_iam_member.viewer, google_project_iam_member.editor
  ]
}
