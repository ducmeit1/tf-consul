terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

module "consul_server" {
  source = "github.com/ducmeit1/tf-instance-group-gcp"
  gcp_project         = var.gcp_project
  gcp_region          = var.gcp_region
  gcp_network         = var.gcp_network
  gcp_subnetwork      = var.gcp_subnetwork
  network_project_id  = var.network_project_id
  name                = var.cluster_name
  description         = var.cluster_description
  target_size         = var.cluster_size
  tags                = concat([var.cluster_tag_name], var.custom_tags)
  startup_script      = var.startup_script
  shutdown_script     = var.shutdown_script

  # WARNING! These configuration values are suitable for testing, but for production, see https://www.consul.io/docs/guides/performance.html
  # Production recommendations:
  # - machine_type: At least n1-standard-2 (so that Consul can use at least 2 cores); confirm that you have enough RAM
  #                 to contain between 2 - 4 times the working set size.
  # - root_volume_disk_type: pd-ssd or local-ssd (for write-heavy workloads, use SSDs for the best write throughput)
  # - root_volume_disk_size_gb: Consul's data set is persisted, so this depends on the size of your expected data set
  machine_type = var.machine_type

  root_volume_disk_type    = var.root_volume_disk_type
  root_volume_disk_size_gb = var.root_volume_disk_size_gb

  # In production, you should specify the exact image name to make it clear which image the current Consul servers are
  # deployed with.
  image_project_id = var.image_project_id
  source_image = var.source_image
  family_image = var.family_image


  # This update strategy will performing a rolling update of the Consul cluster server nodes. We wait 5 minutes for
  # the newly created server nodes to become available to ensure they have enough time to join the cluster and
  # propagate the data.
  instance_group_update_policy_type                  = "PROACTIVE"
  instance_group_update_policy_redistribution_type   = "PROACTIVE"
  instance_group_update_policy_minimal_action        = "REPLACE"
  instance_group_update_policy_max_surge_fixed       = length(data.google_compute_zones.available.names)
  instance_group_update_policy_max_unavailable_fixed = 0
  instance_group_update_policy_min_ready_sec         = 300

  service_account_scopes              = var.service_account_scopes
  service_account_roles               = var.service_account_roles
  members                             = var.members

  # Add custom metadata to instances
  custom_metadata = merge(
    {
      "${var.metadata_key_name_for_cluster_size}" = var.cluster_size
    },
    var.custom_metadata
  )
}

# In production, the cluster should be failover by multiple nodes, we would like to deploy in multiple zones of in a region to prevent disaster
data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}

# These steps are requires to use auto cloud cluster join

resource "google_project_iam_custom_role" "default" {
  role_id     = format("custom_role_%s_ig", replace(var.cluster_name, "-", "_"))
  title       = format("Custom Role For Consul Cluster %s-ig", var.cluster_name)
  description = format("Custom role for consul cluster %s-ig", var.cluster_name)
  permissions = var.service_account_custom_permissions
}

resource "google_project_iam_member" "default" {
  for_each = toset(var.service_account_roles)
  project = var.gcp_project
  role    = each.value
  member  = format("serviceAccount:%s", module.consul_server.service_account)
}

resource "google_project_iam_member" "custom" {
  project     = var.gcp_project
  role        = google_project_iam_custom_role.default.id
  member      = format("serviceAccount:%s", module.consul_server.service_account)
}