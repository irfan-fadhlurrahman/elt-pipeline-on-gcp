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

resource "google_compute_address" "dtc-de-ip" {
  name = "dtc-de-ip"
}

module "dtc-de-network" {
  source       = "./network"
  network_name = "dtc-de-network"
  target_tags  = ["vm-dtc-de"]
}

module "vm-dtc-de" {
  source        = "./instance"
  disk_name     = "dtc-de-disk"
  disk_image    = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230114"
  zone          = var.zone
  disk_type     = "pd-balanced"
  disk_size_gb  = 50
  instance_name = "vm-dtc-de"
  instance_type = "c2d-standard-4"
  tags          = ["vm-dtc-de"]
  network_name  = "dtc-de-network"
  ip_address    = google_compute_address.dtc-de-ip.address
}

module "data-lake-storage" {
  source          = "./storage"
  bucket_name     = "${var.project_id}_${var.dataset_name}"
  bucket_location = var.dataset_location
  storage_class   = "STANDARD"
}

module "data-warehouse-bigquery" {
  source             = "./warehouse"
  dataset_id         = var.dataset_name
  project_id         = var.project_id
  warehouse_location = var.dataset_location
}