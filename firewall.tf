resource "google_compute_firewall" "allow_ssh_to_bastion" {
  project = var.project
  name    = "allow-ssh-to-bastion"
  network = google_compute_network.network.self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["bastion"]
}

resource "google_compute_firewall" "allow_ssh_from_bastion" {
    project = var.project
    name = "allow-ssh-from-bastion"
    network = google_compute_network.network.self_link
    direction = "INGRESS"

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    
    source_tags = ["bastion"]
    target_tags = ["bastion-access"]
}