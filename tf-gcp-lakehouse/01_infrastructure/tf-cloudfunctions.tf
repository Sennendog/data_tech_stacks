
# Create a service account for the Cloud Function
resource "google_service_account" "cloud_function_sa" {
  account_id   = "cloud-function-sa"
  display_name = "Cloud Function Service Account"
  project      = data.google_project.project.project_id
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "cloud_function_sa_roles" {
  for_each = toset([
    "roles/dataproc.editor",
    "roles/storage.objectViewer",
    "roles/pubsub.subscriber",
    "roles/cloudfunctions.invoker"
  ])
  project = data.google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}



# cloud function resources (bucket, source code)
resource "google_storage_bucket" "function_bucket" {
  name     = "${data.google_project.project.project_id}-cloudfunction"
  location = var.region
}

data "archive_file" "function_zip" {
  type        = "zip"
  output_path = "../output/gcs_trigger_function.zip"
  source_dir  = "../02_cloudfunctions/gcs_trigger_function"  # Path to your local function code directory
  excludes    = ["venv", "__pycache__"]
}

resource "google_storage_bucket_object" "function_code" {
  name   = "gcs_trigger_function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path  # Path to your local zip file
  depends_on = [ data.archive_file.function_zip ]
}



# Deploy the Cloud Function
resource "google_cloudfunctions2_function" "gcs_trigger_function" {
  name        = "gcs-trigger-function"
  location    = var.region
  description = "Triggers on new files in GCS and starts Spark ingestion"
  depends_on = [ google_storage_bucket_object.function_code ]

  build_config {
    runtime     = "python310"
    entry_point = "gcs_file_trigger"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_code.name        
      }
    }
  }

  service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 300
    service_account_email = google_service_account.cloud_function_sa.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.gcs_topic.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}
