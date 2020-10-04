terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "iac-consul-tf-state"
    prefix = "terraform/state"
  }
}

locals {
  project = "driven-stage-269911"
  region = "asia-southeast1"
  zone = "asia-southeast1-c"
  network = "consul-network"
  subnetwork = "consul-subnetwork"
  ip_cidr_range = "10.126.0.0/20"
  total_nat_ips = "1"
  credentials_file = "credentials.json"
  consul_server_cluster_name = "server-dc1"
  consul_server_cluster_size = 3
  consul_server_cluster_tag_name = "consul"
  consul_startup_script = "/opt/consul/scripts/startup.sh"
  consul_shutdown_script = "/opt/consul/scripts/shutdown.sh"
  consul_server_allowed_inbound_cidr_blocks_http_api = []
  consul_server_allowed_inbound_cidr_blocks_dns = []
  machine_type = "n1-standard-1"
  root_volume_disk_type = "pd-ssd"
  root_volume_disk_size_gb = 50
  consul_server_source_image = ""
}

provider "google" {
  region      = local.region
  project     = local.project
  credentials = file(local.credentials_file)
}

module "network" {
  source = "github.com/ducmeit1/tf-network-gcp"
  gcp_project = local.project
  gcp_region = local.region
  gcp_network = local.network
  gcp_subnetwork = local.subnetwork
  total_nat_ips = local.total_nat_ips
  ip_cidr_range = local.ip_cidr_range
}

module "bastion" {
  source = "github.com/ducmeit1/tf-bastion-gcp"
  name = "bastion-vm"
  gcp_project = local.project
  gcp_region = local.region
  gcp_zone = local.zone
  gcp_network = local.network
  gcp_subnetwork = local.subnetwork
  machine_type = "g1-small"
  disk_size_gb = 10
  image_family = "debian-9-stretch-v20200805"
  preemptible = false
  network_ip_address = "10.126.0.1"
}

module "bucket" {
    source = "github.com/ducmeit1/tf-storage-gcp"
    gcp_project = local.project
    name = "iac-consul-tf-state"
    bucket_location = "ASIA"
    bucket_force_destroy = false
}

module "consul_servers" {
  source = "github.com/ducmeit1/tf-consul-gcp"

  gcp_project         = local.project
  gcp_region          = local.region
  gcp_network         = local.network
  gcp_subnetwork      = local.subnetwork
  cluster_name        = local.consul_server_cluster_name
  cluster_description = "Consul Server cluster"
  cluster_size        = local.consul_server_cluster_size
  cluster_tag_name    = local.consul_server_cluster_tag_name
  startup_script      = local.consul_startup_script
  shutdown_script     = local.consul_shutdown_script

  # Grant API and DNS access to requests originating from the the Consul client cluster we create below.
  allowed_inbound_tags_http_api        = [local.consul_server_cluster_tag_name]
  allowed_inbound_cidr_blocks_http_api = local.consul_server_allowed_inbound_cidr_blocks_http_api

  allowed_inbound_tags_dns        = [local.consul_server_cluster_tag_name]
  allowed_inbound_cidr_blocks_dns = local.consul_server_allowed_inbound_cidr_blocks_dns

  # WARNING! These configuration values are suitable for testing, but for production, see https://www.consul.io/docs/guides/performance.html
  # Production recommendations:
  # - machine_type: At least n1-standard-2 (so that Consul can use at least 2 cores); confirm that you have enough RAM
  #                 to contain between 2 - 4 times the working set size.
  # - root_volume_disk_type: pd-ssd or local-ssd (for write-heavy workloads, use SSDs for the best write throughput)
  # - root_volume_disk_size_gb: Consul's data set is persisted, so this depends on the size of your expected data set
  machine_type = local.machine_type

  root_volume_disk_type    = local.root_volume_disk_type
  root_volume_disk_size_gb = local.root_volume_disk_size_gb

  # WARNING! By specifying just the "family" name of the Image, Google will automatically use the latest Consul image.
  # In production, you should specify the exact image name to make it clear which image the current Consul servers are
  # deployed with.
  source_image = local.consul_server_source_image

  # This update strategy will performing a rolling update of the Consul cluster server nodes. We wait 5 minutes for
  # the newly created server nodes to become available to ensure they have enough time to join the cluster and
  # propagate the data.
  instance_group_update_policy_type                  = "PROACTIVE"
  instance_group_update_policy_redistribution_type   = "PROACTIVE"
  instance_group_update_policy_minimal_action        = "REPLACE"
  instance_group_update_policy_max_surge_fixed       = length(data.google_compute_zones.available.names)
  instance_group_update_policy_max_unavailable_fixed = 0
  instance_group_update_policy_min_ready_sec         = 300
}

data "google_compute_zones" "available" {
  project = local.project
  region  = local.region
}