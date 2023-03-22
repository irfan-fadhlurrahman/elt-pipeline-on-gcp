resource "google_compute_network" "dtcnetwork" {
  name = var.network_name
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "dtcnetwork-allow-http-ssh-rdp-icmp" {
  name    = "dtcnetwork-allow-http-ssh-rdp-icmp"
  network = google_compute_network.dtcnetwork.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }

  target_tags   = var.target_tags
  source_ranges = ["0.0.0.0/0"]
}