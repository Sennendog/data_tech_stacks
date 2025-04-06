
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
