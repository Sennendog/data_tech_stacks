# Enable required APIs


resource "google_project_service" "cloud_functions" {
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "eventarc" {
  service = "eventarc.googleapis.com"
}

resource "google_project_service" "dataproc" {
  service = "dataproc.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "biglake" {
  service = "biglake.googleapis.com"
}
