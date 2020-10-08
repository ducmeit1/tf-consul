# Allow Consul-specific traffic within the cluster
# - This Firewall Rule may be redundant depnding on the settings of your VPC Network, but if your Network is locked down,
#   this Rule will open up the appropriate ports.
resource "google_compute_firewall" "allow_intracluster_consul" {
  project = var.network_project_id != null ? var.network_project_id : var.gcp_project

  name    = "${var.cluster_name}-rule-cluster"
  network = var.gcp_network

  allow {
    protocol = "tcp"

    ports = [
      var.server_rpc_port,
      var.cli_rpc_port,
      var.serf_lan_port,
      var.serf_wan_port,
      var.http_api_port,
      var.https_api_port,
      var.dns_port,
      var.grpc_port,
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      var.serf_lan_port,
      var.serf_wan_port,
      var.dns_port,
    ]
  }

  source_tags = [var.cluster_tag_name]
  target_tags = [var.cluster_tag_name]
}

# Specify which traffic is allowed into the Consul Cluster solely for HTTP API requests
# - This Firewall Rule may be redundant depnding on the settings of your VPC Network, but if your Network is locked down,
#   this Rule will open up the appropriate ports.
# - This Firewall Rule is only created if at least one source tag or source CIDR block is specified.
resource "google_compute_firewall" "allow_inbound_http_api" {
  count = length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0

  project = var.network_project_id != null ? var.network_project_id : var.gcp_project

  name    = "${var.cluster_name}-rule-external-api-access"
  network = var.gcp_network

  allow {
    protocol = "tcp"

    ports = [
      var.http_api_port,
      var.https_api_port
    ]
  }

  source_ranges = var.allowed_inbound_cidr_blocks_http_api
  source_tags   = var.allowed_inbound_tags_http_api
  target_tags   = [var.cluster_tag_name]
}

# Specify which traffic is allowed into the Consul Cluster solely for DNS requests
# - This Firewall Rule may be redundant depnding on the settings of your VPC Network, but if your Network is locked down,
#   this Rule will open up the appropriate ports.
# - This Firewall Rule is only created if at least one source tag or source CIDR block is specified.
resource "google_compute_firewall" "allow_inbound_dns" {
  count = length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0

  project = var.network_project_id != null ? var.network_project_id : var.gcp_project

  name    = "${var.cluster_name}-rule-external-dns-access"
  network = var.gcp_network

  allow {
    protocol = "tcp"

    ports = [
      var.dns_port,
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      var.dns_port,
    ]
  }

  source_ranges = var.allowed_inbound_cidr_blocks_dns
  source_tags   = var.allowed_inbound_tags_dns
  target_tags   = [var.cluster_tag_name]
}