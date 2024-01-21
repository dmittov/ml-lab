resource "google_vertex_ai_feature_group" "house_main" {
  name = "house_main"
  description = "The main house feature group"
  big_query {
    big_query_source {
        input_uri = "bq://${google_bigquery_table.house_features.project}.${google_bigquery_table.house_features.dataset_id}.${google_bigquery_table.house_features.table_id}"
    }
  }
}

resource "google_vertex_ai_feature_group" "house_price" {
  name = "house_price"
  description = "The house purchase events"
  big_query {
    big_query_source {
        input_uri = "bq://${google_bigquery_table.house_features.project}.${google_bigquery_table.house_features.dataset_id}.${google_bigquery_table.house_features.table_id}"
    }
  }
}


resource "google_vertex_ai_feature_group" "house_eu_size" {
  name = "house_eu_size"
  description = "The house areas in sq meters"
  big_query {
    big_query_source {
        input_uri = "bq://${google_bigquery_table.house_features.project}.${google_bigquery_table.house_features.dataset_id}.${google_bigquery_table.house_size_eu.table_id}"
    }
  }
}

# google_vertex_ai_feature_group is supported, but
# google_vertex_ai_feature_group_feature is still in progress
#
# https://github.com/hashicorp/terraform-provider-google/issues/16516
# PR: https://github.com/GoogleCloudPlatform/magic-modules/pull/9692
