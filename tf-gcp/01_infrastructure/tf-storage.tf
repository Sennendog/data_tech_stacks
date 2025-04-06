# gcp cloud storage bucket
resource "google_storage_bucket" "datalake_storage" {
  name     = "tf-gcp-datalake"
  location = var.region
  uniform_bucket_level_access = true
  hierarchical_namespace {
    enabled = true
  }  
}


# create folders in the bucket
resource "google_storage_folder" "datalake_landingzone_folder" {
  name   = "landingzone/"
  bucket = google_storage_bucket.datalake_storage.name
}

resource "google_storage_folder" "datalake_iceberg_folder" {
  name   = "iceberg/"
  bucket = google_storage_bucket.datalake_storage.name
}
