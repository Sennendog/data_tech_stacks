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
  cloud_resource {}    
}

resource "google_storage_bucket_iam_member" "biglake_storage_access" {
  bucket = google_storage_bucket.iceberg_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_bigquery_connection.biglake_iceberg_connection.cloud_resource[0].service_account_id}"

  depends_on = [
    google_bigquery_connection.biglake_iceberg_connection
  ]
}


# prepare sql execution and run via bq command line
resource "local_file" "rendered_sql" {
  filename = "../output/create_iceberg.sql"
  content = templatefile("../04_bigquery/create_iceberg.sql", {
      connection_name = google_bigquery_connection.biglake_iceberg_connection.id
      storage_uri = "gs://${google_storage_bucket.iceberg_storage.name}/"
  })

  depends_on = [google_bigquery_connection.biglake_iceberg_connection]
}

resource "null_resource" "run_bigquery_sql" {
  provisioner "local-exec" {
    command = "bq query --nouse_legacy_sql --project_id=${data.google_project.project.project_id} < ../output/create_iceberg.sql"
  }

  depends_on = [local_file.rendered_sql]
}
