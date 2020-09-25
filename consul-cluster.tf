locals {
    machine_type = "n2d-standard-2"
    image = "ubuntu-1804-lts"
    disk = "50"
    es_consul_instance_lists = [
    {
      name          = "consul-1"
      zone          = var.zone
      machine_type  = local.machine_type
      private_ip    = "10.127.0.3"
    },
    {
      name       = "consul-2"
      zone       = var.zone
      machine_type  = local.machine_type
      private_ip = "10.127.0.4"
    },
    {
      name       = "consul-3"
      zone       = var.zone
      machine_type  = local.machine_type
      private_ip = "10.127.0.5"
    },
  ]
}

resource "google_compute_instance" "vm_consul_cluster" {
  for_each = { for vm in local.es_consul_instance_lists:vm.name => vm }
  name = each.value.name
  machine_type = each.value.machine_type
  zone = each.value.zone
  tags = ["bastion-access", "consul-cluster"]
  boot_disk {
    initialize_params {
      image = local.image
      size = local.disk
    }
  }

  network_interface {
    network = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = each.value.private_ip
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  service_account {
    email = google_service_account.consul-cluster.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  metadata_startup_script = <<EOT
    curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh && sudo bash install-monitoring-agent.sh
  EOT
}
