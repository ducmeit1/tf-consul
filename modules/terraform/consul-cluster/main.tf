terraform {
    required_version = ">= 0.12"
}

# Create the Regional Managed Instance Group where Consul Server will live.
resource "google_compute_region_instance_group_manager" "consul_server" {
  project = var.gcp_project_id
  name    = format("%s-ig", var.cluster_name)

  base_instance_name = var.cluster_name
  region             = var.gcp_region

  version {
    instance_template = google_compute_instance_template.consul_server.self_link
  }

  # Consul Server is a stateful cluster, so the update strategy used to roll out a new GCE Instance Template must be
  # a rolling update.
  update_policy {
    type                         = var.instance_group_update_policy_type
    instance_redistribution_type = var.instance_group_update_policy_redistribution_type
    minimal_action               = var.instance_group_update_policy_minimal_action
    max_surge_fixed              = var.instance_group_update_policy_max_surge_fixed
    max_surge_percent            = var.instance_group_update_policy_max_surge_percent
    max_unavailable_fixed        = var.instance_group_update_policy_max_unavailable_fixed
    max_unavailable_percent      = var.instance_group_update_policy_max_unavailable_percent
    min_ready_sec                = var.instance_group_update_policy_min_ready_sec
  }

  target_pools = var.instance_group_target_pools
  target_size  = var.cluster_size

  depends_on = [
    google_compute_instance_template.consul_server
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Create the Instance Template that will be used to populate the Managed Instance Group.
resource "google_compute_instance_template" "consul_server" {
  project = var.gcp_project_id

  name_prefix = var.cluster_name
  description = var.cluster_description

  instance_description = var.cluster_description
  machine_type         = var.machine_type

  tags                    = concat([var.cluster_tag_name], var.custom_tags)
  metadata_startup_script = var.startup_script
  metadata = merge(
    {
      "${var.metadata_key_name_for_cluster_size}" = var.cluster_size,

      # The Terraform Google provider currently doesn't support a `metadata_shutdown_script` argument so we manually
      # set it here using the instance metadata.
      "shutdown-script" = var.shutdown_script
    },
    var.custom_metadata,
  )

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  disk {
    boot         = true
    auto_delete  = true
    source_image = data.google_compute_image.image.self_link
    disk_size_gb = var.root_volume_disk_size_gb
    disk_type    = var.root_volume_disk_type
  }

  network_interface {
    network            = var.subnetwork_name != null ? null : var.network_name
    subnetwork         = var.subnetwork_name != null ? var.subnetwork_name : null
    subnetwork_project = var.network_project_id != null ? var.network_project_id : null
  }

  service_account {
    email = google_service_account.consul-cluster.email
    scopes = concat(
      ["userinfo-email", "compute-ro", var.storage_access_scope],
      var.service_account_scopes,
    )
  }

  # Per Terraform Docs (https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#using-with-instance-group-manager),
  # we need to create a new instance template before we can destroy the old one. Note that any Terraform resource on
  # which this Terraform resource depends will also need this lifecycle statement.
  lifecycle {
    create_before_destroy = true
  }
}

# This is a workaround for a provider bug in Terraform v0.11.8. For more information please refer to:
# https://github.com/terraform-providers/terraform-provider-google/issues/2067.
data "google_compute_image" "image" {
  name    = var.source_image
  project = var.image_project_id != null ? var.image_project_id : var.gcp_project_id
}