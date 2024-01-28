resource "google_vertex_ai_feature_group" "house_area" {
  name = "house_area"
  description = "The main house feature group"
  big_query {
    big_query_source {
        input_uri = "bq://${google_bigquery_table.ai_house_area.project}.${google_bigquery_table.ai_house_area.dataset_id}.${google_bigquery_table.ai_house_area.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }
}

resource "google_vertex_ai_feature_group" "house_price" {
  name = "house_price"
  description = "The house purchase events"
  big_query {
    big_query_source {
        input_uri = "bq://${google_bigquery_table.ai_house_prices.project}.${google_bigquery_table.ai_house_prices.dataset_id}.${google_bigquery_table.ai_house_prices.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }
}

# google_vertex_ai_feature_group is supported, but
# google_vertex_ai_feature_group_feature is still in progress
#
# https://github.com/hashicorp/terraform-provider-google/issues/16516
# PR: https://github.com/GoogleCloudPlatform/magic-modules/pull/9692

### Online Serving

resource "google_vertex_ai_feature_online_store" "house_pricing" {
  name = "house_pricing"
  # optimized serving is already in preview and it's declared to have
  # much better response time, but it requires big_query / online_store sync
  # that consumes biqquery resources and costs money, very often syncs are not
  # welcomed
  #
  # overall: bigtable: worse latency, better costs
  bigtable {
    auto_scaling {
      min_node_count         = 1
      max_node_count         = 3
      cpu_utilization_target = 80
    }
  }
#  attribute is not in production yet
#  
#   embedding_management {
#     enabled = false  # out of scope for now
#   }
  force_destroy = true
}

# resource "google_vertex_ai_feature_online_store_featureview" "featureview" {
#   name                 = "example_feature_view"
#   region               = "us-central1"
#   feature_online_store = google_vertex_ai_feature_online_store.featureonlinestore.name
#   sync_config {
#     cron = "0 0 * * *"
#   }
#   big_query_source {
#     uri               = "bq://${google_bigquery_table.tf-test-table.project}.${google_bigquery_table.tf-test-table.dataset_id}.${google_bigquery_table.tf-test-table.table_id}"
#     entity_id_columns = ["test_entity_column"]

#   }
# }