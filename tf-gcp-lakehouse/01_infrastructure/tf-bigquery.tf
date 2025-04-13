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

resource "google_bigquery_connection" "biglake_iceberg_connection" {
  location      = var.region
  description = "BigLake connection to GCS bucket"
  cloud_resource {
  }    
}

resource "google_storage_bucket_iam_member" "biglake_storage_access" {
  bucket = google_storage_bucket.datalake_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:bqcx-${data.google_project.project.number}-cyl9@gcp-sa-bigquery-condel.iam.gserviceaccount.com"
}
