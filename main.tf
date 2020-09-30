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