output "gcp_project" {
  value = var.gcp_project
}

output "gcp_region" {
  value = var.gcp_region
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_tag_name" {
  value = var.cluster_tag_name
}

output "instance_group_url" {
  value = module.consul_server.instance_group_url
}

output "instance_group_name" {
  value = module.consul_server.instance_group_name
}

output "instance_template_url" {
  value = module.consul_server.instance_template_url
}

output "instance_template_name" {
  value = module.consul_server.instance_template_name
}

output "instance_template_metadata_fingerprint" {
  value = module.consul_server.instance_template_metadata_fingerprint
}

output "firewall_rule_intracluster_url" {
  value = google_compute_firewall.allow_intracluster_consul.self_link
}

output "firewall_rule_intracluster_name" {
  value = google_compute_firewall.allow_intracluster_consul.name
}

output "firewall_rule_inbound_http_url" {
  value = element(
    concat(
      google_compute_firewall.allow_inbound_http_api.*.self_link,
      [""],
    ),
    0,
  )
}

output "firewall_rule_inbound_http_name" {
  value = element(
    concat(google_compute_firewall.allow_inbound_http_api.*.name, [""]),
    0,
  )
}

output "firewall_rule_inbound_dns_url" {
  value = element(
    concat(google_compute_firewall.allow_inbound_dns.*.self_link, [""]),
    0,
  )
}

output "firewall_rule_inbound_dns_name" {
  value = element(
    concat(google_compute_firewall.allow_inbound_dns.*.name, [""]),
    0,
  )
}

output "service_account" {
    value = module.consul_server.service_account
}