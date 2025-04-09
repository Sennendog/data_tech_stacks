
# Create a service account for the Cloud Function
resource "google_service_account" "cloud_function_sa" {
  account_id   = "cloud-function-sa"
  display_name = "Cloud Function Service Account"
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "cloud_function_sa_roles" {
  for_each = toset([
    "roles/dataproc.editor",
    "roles/storage.objectViewer",
    "roles/pubsub.subscriber"
  ])
  project = data.google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

