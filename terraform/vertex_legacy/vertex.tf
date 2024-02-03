resource "google_vertex_ai_featurestore" "featurestore" {
  name     = "realestate"
  online_serving_config {
    scaling {
      min_node_count = 1
      max_node_count = 2
    }
  }
}

resource "google_vertex_ai_featurestore_entitytype" "house" {
  name     = "house"
  featurestore = google_vertex_ai_featurestore.featurestore.id
  monitoring_config {
    snapshot_analysis {
        disabled = false
        monitoring_interval_days = 1
        staleness_days = 21  # default
    }
    # Anomaly detection
    categorical_threshold_config {
      value = 0.3  # L-infinity norm 
    }
    numerical_threshold_config {
      value = 0.3  # Jensen–Shannon divergence between 
    }
    import_features_analysis {
        state = "ENABLED"
        anomaly_detection_baseline = "LATEST_STATS"
    }
  }
  # If unset (or explicitly set to 0), default to 4000 days TTL
  # is not recognized by the latest TF
  # offline_storage_ttl_days = 0
}

resource "google_vertex_ai_featurestore_entitytype_feature" "flr_one_sq_feet" {
  name     = "flr_one_sq_feet"
  entitytype = google_vertex_ai_featurestore_entitytype.house.id
  value_type = "INT64"  # can be INT64_ARRAY / STRING / BYTES
  description = "Area of the 1st floor in sq feet"
}

resource "google_vertex_ai_featurestore_entitytype_feature" "flr_two_sq_feet" {
  name     = "flr_two_sq_feet"
  entitytype = google_vertex_ai_featurestore_entitytype.house.id
  value_type = "INT64"
  description = "Area of the 2nd floor in sq feet"
}

resource "google_vertex_ai_featurestore_entitytype_feature" "sale_price" {
  name     = "sale_price"
  entitytype = google_vertex_ai_featurestore_entitytype.house.id
  value_type = "DOUBLE"
  description = "House sale price"
}
