resource "google_compute_firewall" "allow_ssh_to_bastion" {
  project = var.project
  name    = "allow-ssh-to-bastion"
  network = var.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = var.source_tags
}

resource "google_compute_firewall" "allow_ssh_from_bastion" {
    project = var.project
    name = "allow-ssh-from-bastion"
    network = var.network_name
    direction = "INGRESS"

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports = ["22", "80", "443", "8888", "5601", "9200"]
    }
    
    source_tags = var.source_tags
    target_tags = var.target_tags
}