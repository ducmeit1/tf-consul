output "network_self_link" {
    description = "Self link of the network"
    value = google_compute_network.network.self_link
}

output "subnetwork_self_link" {
    description = "Self link of the sub-network"
    value = google_compute_subnetwork.subnet.self_link
}

output "nat_ip_self_link" {
    description = "Self link of the nat ips"
    value = google_compute_address.nat-ips.*.self_link
}

output "router_self_link" {
    description = "Self link of the router"
    value = google_compute_router.router.self_link
}