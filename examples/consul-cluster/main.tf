terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket  = "iac-terraform-state-bucket"
    prefix  = "terraform/state"
  }
}

provider "google" {
  region      = var.region
  version     = "~> 3.26"
}

locals {
    nat_subnetwork = concat([var.subnetwork_name])
}

module "network" {
    source = "./modules/terraform/network"
    project = var.project
    region = var.region
    network_name = var.network_name
    subnetwork_name = var.subnetwork_name
    nat_subnetwork_names = local.nat_subnetwork
}

module "bastion" {
    source = "./modules/terraform/bastion"
    project = var.project
    region = var.region
    zone = var.zone
    network_name = var.network_name
    subnetwork_name = var.subnetwork_name
    network_url = module.network.network_self_link
    subnetwork_url = module.network.subnetwork_self_link
    members = var.members
}

module "storage" {
    source = "./modules/terraform/storage"
    project = var.project
    location = var.storage_location
}

module "consul_server_cluster" {
  source = "./modules/terraform/consul-cluster"
  project = var.project
  region = var.region
  cluster_name = 
}
##-----------------------------------
# This is for testing a standalone vm
##-----------------------------------

locals {
  image_source = "debian-9-stretch-v20200805"
}

resource "google_service_account" "vm-consul" {
    project = var.project
    account_id = "vm-consul"
    display_name = "Service account for vm consul"
}

resource "google_service_account_iam_member" "vm-consul-sa" {
    service_account_id = google_service_account.vm-consul.id
    role = "roles/iam.serviceAccountUser"
    member = format("serviceAccount:%s", google_service_account.vm-consul.email)
}

resource "google_compute_instance" "vm_consul" {
  name = "vm-consul"
  project = var.project
  machine_type = "n1-standard-2"
  zone = "asia-east1-c"
  tags = ["bastion-access", "consul"]
  boot_disk {
    initialize_params {
      image = local.image_source
      size = 20
    }
  }

  network_interface {
    network = module.network.network_self_link
    subnetwork = module.network.subnetwork_self_link
    network_ip = "10.127.0.3"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  service_account {
    email = google_service_account.vm-consul.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  allow_stopping_for_update = true

  metadata_startup_script = <<EOT
    curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh && sudo bash install-monitoring-agent.sh
  EOT
}