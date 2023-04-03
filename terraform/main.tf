terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials)
}

module "data-lake-storage" {
  source          = "./storage"
  bucket_name     = "${var.project_id}_data_lake"
  bucket_location = var.dataset_location
  storage_class   = "STANDARD"
}

module "data-warehouse-bigquery" {
  source             = "./warehouse"
  dataset_id         = "data_warehouse"
  project_id         = var.project_id
  warehouse_location = var.dataset_location
}