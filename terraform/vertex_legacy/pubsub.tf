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
    schema   = "projects/${google_pubsub_schema.house_area.project}/schemas/house_area"
    encoding = "BINARY"
  }
}

resource "google_pubsub_topic" "house_prices" {
  name       = "house_prices"
  depends_on = [google_pubsub_schema.house_prices]

  schema_settings {
    schema   = "projects/${google_pubsub_schema.house_prices.project}/schemas/house_prices"
    encoding = "BINARY"
  }
}

resource "google_pubsub_subscription" "house_area" {
  name  = "house_area_to_fs"
  topic = google_pubsub_topic.house_area.id
  ack_deadline_seconds = 20
}
