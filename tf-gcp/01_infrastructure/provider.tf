
# use GCP provider
# see: https://registry.terraform.io/providers/hashicorp/google/latest

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = file(var.project_id_file)
  region  = var.region
  zone    = var.zone
  credentials = file(var.credentials_file)
}

data "google_project" "project" {
  project_id = file(var.project_id_file)
}

output "project_id" {
  value = data.google_project.project.project_id
}
output "project_number" {
  value = data.google_project.project.number
}
output "project_name" {
  value = data.google_project.project.name
}
