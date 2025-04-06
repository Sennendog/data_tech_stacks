variable "project_id_file" {
  description = "The path to the file containing the project ID of the project in which the resources will be created."
  type        = string
}
variable "region" {
  description = "The region in which the resources will be created."
  type        = string
}
variable "zone" {
  description = "The zone in which the resources will be created."
  type        = string
}
variable "credentials_file" {
  description = "The path to the service account key file."
  type        = string
}

variable "environment" {
  description = "The environment in which the resources will be created."
  type        = string
}
