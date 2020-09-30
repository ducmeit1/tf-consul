terraform {
    required_version = ">= 0.12"
}

resource "google_compute_network" "network" {
  project                 = var.project
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project                  = var.project
  name                     = var.subnetwork_name
  region                   = var.region
  ip_cidr_range            = var.ip_cidr_range
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}

resource "google_compute_address" "nat-ips" {
  count = var.total_nat_ips
  name = format("nat-manual-ip-%s", count.index)
  project = var.project
  region = var.region
}

resource "google_compute_router" "router" {
  project = var.project
  region = var.region
  name = format("%s-router", var.network_name)
  network = google_compute_network.network.self_link
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "router-nat" {
  project = var.project
  name = format("%s-nat-gw", var.network_name)
  router = google_compute_router.router.name
  region = var.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.nat-ips.*.self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  dynamic "subnetwork" {
    for_each = toset(var.nat_subnetwork_names)
    content {
      name = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}