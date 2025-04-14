resource "google_storage_bucket" "dataproc_bucket" {
  name     = "${data.google_project.project.project_id}-dataproc"
  location = var.region
}


resource "google_storage_bucket_object" "dataproc_ingest_job" {
  name   = "dataproc_ingest_job.py"
  bucket = google_storage_bucket.dataproc_bucket.name
  source = "../03_dataproc/dataproc_ingest_job.py" # Path to your local zip file
}
