variable "project_id" {
  description = "Your GCP Project ID"
}
variable "credentials" {
  description = "Your GCP credentials path location"
}
variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
}
variable "zone" {
  description = "Zone for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
}
variable "dataset_name" {
  description = "Dataset you currently use for the project"
}
variable "dataset_location" {
  description = "Location of your dataset. To use dbt you should store the dataset on US"
}