
# gcp cloud storage bucket
resource "google_storage_bucket" "datalake_storage" {
  name     = "${data.google_project.project.project_id}-tf-gcp-landingzone"
  location = var.region
  uniform_bucket_level_access = true
  hierarchical_namespace {
    enabled = true
  }  
}

resource "google_storage_bucket" "iceberg_storage" {
  name     = "${data.google_project.project.project_id}-tf-gcp-iceberg"
  location = var.region
  uniform_bucket_level_access = true
  hierarchical_namespace {
    enabled = true
  }  
}


# Create a Pub/Sub topic for GCS notifications
resource "google_pubsub_topic" "gcs_topic" {
  name = "tf-gcp-datalake-events"

  message_retention_duration = "86400s" # 7 days (max allowed is 31 days = 2678400s)

  labels = {
    environment = var.environment
  }  
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

