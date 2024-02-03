# Vertex AI Feature Store

There are 2 options for the feature store in the Google cloud.

* Feature Store
* Feature Store (legacy)

On the current UI the Legacy version is a default one. Python SDK also supports just the legacy option.

[Example Notebooks](https://github.com/GoogleCloudPlatform/vertex-ai-samples/blob/main/notebooks/official/feature_store/feature_store_streaming_ingestion_sdk.ipynb) mostly illustrate legacy FS usage.

All Terraform code and example notebooks are going to be removed from the main branch.

## Legacy

* Can create objects with Terraform
* Can ingest using streaming
* Back ingest using pandas df fails
* [Can't retrieve features](https://github.com/googleapis/python-aiplatform/issues/3247)
Nobody reacted in a week.

## The new Feature Store

Some of the objects are supported by Terraform, others are not yet.

* aiplatform: not supported
* aiplatform_v1: supported, but fails
* aiplatform_v1beta1: supported, but fails with some other issues
* direct HTTP request: works

It's easy to ingest data into the offline (BigQuery) store. But the online store
sync runs on cron schedule. No way to ingest data directly for now.

After successful data sync I was still not able to get the features from the
feature store. The query returned an empty result.

There is no API to get the training dataset, Google recommends requesting
BigQuery directly. This works, but I'm not sure `row_number()` approach is
optimal.

## Additional issues

After removing all the objects I was still billed $22.50 a day for BigTable.
Disabling the Vertex API helped.
