# How to execute/deploy this project

## DEPLOY (once)

### Setup Service Account permissions for terraform
    cd 00_prepare_gcp_serviceaccount
    Linux: ./gcp-prepapre.sh
    Windows: ./gcp-prepapre.ps1


### Setup infrastructure (terraform)
    cd 01_infrastructure
    terraform init  # first time only
    terraform plan -var-file="env_dev.tfvars"
    terraform apply -var-file="env_dev.tfvars"


### Check results
    You should now have:
    * GCS bucket "PROJECTID-tf-gcp-landingzone"
    * GCS bucket "PROJECTID-tf-gcp-iceberg"
    * several other gcs buckets for cloud run and dataproc
    * BigQuery dataset "datalake"
    * BigQuery external table "iceberg_table", stored in the "PROJECTID-tf-gcp-iceberg" bucket
    * a cloud run function "gcs-trigger-function"
    * Pub/Sub topic "tf-gcp-datalake-events" connected to the landignzone bucket and the cloud run function


## RUN (repeatbale)

### Run BigQuery query
    Query the "iceberg_table" to see that it is empty (initially)


### Upload .CSV file from 05_sample_data to bucket "PROJECTID-tf-gcp-landingzone"
    Manually drop the file or use gcloud cli to upload the CSV file


### Wait for the Dataproc Spark job to finish
    Then query "iceberg_table" again in bigquery to see the rows from the csv file

