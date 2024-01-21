resource "google_bigquery_dataset" "house_pricing" {
  dataset_id                  = "house_pricing"
  friendly_name               = "house_pricing"
  description                 = "This a dataset to store HousePricing domain data assets"
  location                    = "EU"
  default_table_expiration_ms = 3600000
}

resource "google_bigquery_table" "house_features" {
  dataset_id          = google_bigquery_dataset.house_pricing.dataset_id
  table_id            = "house_features"
  deletion_protection = false

  time_partitioning {
    type = "MONTH"
    field = "house_valuation_timestamp"
  }
  schema = <<EOF
[
  {"name": "house_id", "type": "STRING"},
  {"name": "house_valuation_timestamp", "type": "TIMESTAMP", "default": "CURRENT_TIMESTAMP"},
  {"name": "flr_one_sq_feet", "type": "INTEGER"},
  {"name": "flr_two_sq_feet", "type": "INTEGER"},
  {"name": "attributes", "type": "STRING", "mode": "REQUIRED"},
  {"name": "subscription_name", "type": "STRING", "mode": "REQUIRED"},
  {"name": "message_id", "type": "NUMERIC", "mode": "REQUIRED"},
  {"name": "publish_time", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
EOF
}

resource "google_bigquery_table" "house_prices" {
  dataset_id          = google_bigquery_dataset.house_pricing.dataset_id
  table_id            = "house_price"
  deletion_protection = false

  time_partitioning {
    type = "MONTH"
    field = "sale_timestamp"
  }
  schema = <<EOF
[
  {"name": "house_id", "type": "STRING"},
  {"name": "sale_timestamp", "type": "TIMESTAMP", "default": "CURRENT_TIMESTAMP"},
  {"name": "sale_price", "type": "INTEGER"},
  {"name": "attributes", "type": "STRING", "mode": "REQUIRED"},
  {"name": "subscription_name", "type": "STRING", "mode": "REQUIRED"},
  {"name": "message_id", "type": "NUMERIC", "mode": "REQUIRED"},
  {"name": "publish_time", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
EOF
}

resource "google_bigquery_table" "ai_house_features" {
  dataset_id          = google_bigquery_dataset.house_pricing.dataset_id
  table_id            = "ai_house_features"
  deletion_protection = false

  view {
    use_legacy_sql = false
    query = <<EOF
  select house_id entity_id,
         house_valuation_timestamp feature_timestamp,
         flr_one_sq_feet,
         flr_two_sq_feet,
         (flr_one_sq_feet + flr_two_sq_feet) house_sq_feet
  from ${google_bigquery_dataset.house_pricing.dataset_id}.${google_bigquery_table.house_features.table_id}
  ;
  EOF
  }
}

resource "google_bigquery_table" "ai_house_prices" {
  dataset_id          = google_bigquery_dataset.house_pricing.dataset_id
  table_id            = "ai_house_prices"
  deletion_protection = false

  view {
    use_legacy_sql = false
    query = <<EOF
  select house_id entity_id,
         house_valuation_timestamp feature_timestamp,
         flr_one_sq_feet,
         flr_two_sq_feet,
         (flr_one_sq_feet + flr_two_sq_feet) house_sq_feet
  from ${google_bigquery_dataset.house_pricing.dataset_id}.${google_bigquery_table.house_prices.table_id}
  ;
  EOF
  }
}
