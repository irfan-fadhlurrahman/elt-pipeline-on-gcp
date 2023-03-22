resource "google_compute_disk" "vm-disk" {
  name  = var.disk_name
  image = var.disk_image
  zone  = var.zone
  type  = var.disk_type
  size  = var.disk_size_gb
}
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  zone         = var.zone
  machine_type = var.instance_type
  tags         = var.tags

  boot_disk {
    source = google_compute_disk.vm-disk.self_link
  }
  network_interface {
    network = var.network_name
    access_config {
      nat_ip = var.ip_address
    }
  }

  allow_stopping_for_update = true

}