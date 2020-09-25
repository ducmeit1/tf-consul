module "iap_bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  project = var.project
  zone    = var.zone
  network = google_compute_network.network.self_link
  subnet  = google_compute_subnetwork.subnet.self_link
  members = var.members
  machine_type = "g1-small"
  tags = ["bastion"]
  disk_size_gb = "10"
  image_family = "ubuntu-1804-lts"
}
