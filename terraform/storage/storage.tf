resource "google_storage_bucket" "data-lake-bucket" {
  name          = var.bucket_name
  location      = var.bucket_location
  storage_class = var.storage_class

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # days
    }
  }

  uniform_bucket_level_access = true
  force_destroy               = true
}