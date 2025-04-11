
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



# Create a Pub/Sub topic for GCS notifications
resource "google_pubsub_topic" "gcs_topic" {
  name = "tf-gcp-datalake-events"
}

resource "google_pubsub_topic_iam_member" "gcs_publisher" {
  topic = google_pubsub_topic.gcs_topic.name
  role  = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Configure the GCS bucket to send notifications to the Pub/Sub topic
resource "google_storage_notification" "gcs_notification" {
  bucket         = google_storage_bucket.datalake_storage.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.gcs_topic.id
  event_types    = ["OBJECT_FINALIZE"]
}

