# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
    required_version = ">= 0.12"
}

module "iap_bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  project = var.project
  zone    = var.zone
  network = var.network_url
  subnet  = var.subnetwork_url
  members = var.members
  machine_type = var.machine_type
  tags = var.source_tags
  disk_size_gb = var.disk_size_gb
  image_family = var.image_family
}