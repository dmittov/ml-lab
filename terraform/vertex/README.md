# Vertex AI Feature Store

## Queue DataType [AVRO]

Because we'd like to achieve impressive performance for the solution, the main
two options are:

* Apache AVRO
* Google Protocol Buffers 3 (aka protobuf)

Protocol Buffers 3 is faster. But the support of required/optional fields was
[consciously dropped](https://github.com/protocolbuffers/protobuf/issues/2497).

Assume all columns are nullable in the BigQuery tables.

<!-- While schema validation GCP compares nullable attributes between Pub/Sub and
BigQuery. So, because of the integration issues, it's better to choose Avro.
Also, Avro is used in Google tutorials. -->

## Pub/Sub / BigQuery type casting

https://cloud.google.com/pubsub/docs/bigquery#protocol-buffer-types

## Training dataset

https://sagemaker.readthedocs.io/en/stable/api/prep_data/feature_store.html#dataset-builder

https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-create-a-dataset.html

Complicated join logic tuning.

```python
base_data = [[1, 187512346.0, 123, 128],
             [2, 187512347.0, 168, 258],
             [3, 187512348.0, 125, 184],
             [1, 187512349.0, 195, 206]]
base_data_df = pd.DataFrame(
    base_data, 
    columns=["base_id", "base_time", "base_feature_1", "base_feature_2"]
)

###
base_fg_name = "base_fg_name"
base_fg = FeatureGroup(name=base_fg_name, sagemaker_session=feature_store_session)

first_fg_name = "first_fg_name"
first_fg = FeatureGroup(name=first_fg_name, sagemaker_session=feature_store_session)

second_fg_name = "second_fg_name"
second_fg = FeatureGroup(name=second_fg_name, sagemaker_session=feature_store_session)

feature_store = FeatureStore(feature_store_session)
builder = feature_store.create_dataset(
    base=base_fg,
    output_path=f"s3://{DOC-EXAMPLE-BUCKET1}",
).with_feature_group(first_fg
).with_feature_group(second_fg, "base_id", ["base_feature_1"])         
###

builder = feature_store.create_dataset(
    base=base_data_df, 
    event_time_identifier_feature_name='base_time', 
    record_identifier_feature_name='base_id',
    output_path=f"s3://{s3_bucket_name}"
).with_feature_group(first_fg
).with_feature_group(second_fg, "base_id", ["base_feature_1"])            
```
