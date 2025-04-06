# bigquery dataset
resource "google_bigquery_dataset" "datalake_dataset" {
  dataset_id    = "datalake"
  friendly_name = "Datalake_Dataset"
  description   = "Dataset for iceberg tables"
  location      = var.region

  labels = {
    environment = var.environment
  }
}

