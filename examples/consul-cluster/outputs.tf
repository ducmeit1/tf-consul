output "gcp_project_id" {
    description = "The GCP Project id where resources provisioned on GCP"
    value = var.project
}

output "gcp_region" {
    description = "The GCP Region where resources provisioned on GCP"
    value = var.region
}

output "gcp_zone" {
    description = "The GCP Zone where resources provisioned on GCP"
    value = var.zone
}

output "gcp_network_url" {
    description = "The GCP Network's URL which is provisioned on GCP" 
    value = module.network.network_self_link
}

output "gcp_subnetwork_url" {
    description = "The GCP Sub Network's URL which is provisioned on GCP"
    value = module.network.subnetwork_self_link
}

output "gcp_nat_ip_address_url" {
    description = "The GCP Cloud Nat IP Addresses's URL which is provisioned on GCP"
    value = module.network.nat_ip_self_link
}

output "gcp_bastion_host_name" {
    description = "The GCP Bastion Host's Host Name which is provisioned on GCP "
    value = module.bastion.hostname
}

output "gcp_bastion_host_ip" {
    description = "The GCP Bastion Host's IP Address which is provisioned on GCP"
    value = module.bastion.ip_address
}

output "gcp_bastion_host_url" {
    description = "The GCP Bastion Host's URL which is provisioned on GCP"
    value = module.bastion.self_link
}

output "gcp_bastion_service_account" {
    description = "The email for the service account created for the bastion host"
    value = module.bastion.service_account
}

output "gcp_bastion_instance_template_url" {
    description = "The GCP Bastion Host's Instance Template URL which is provisioned on GCP"
    value = module.bastion.instance_template
}

output "gcp_storage_name" {
    description = "The Google Storage Bucket's Name which is provisioned on GCP"
    value = module.storage.storage_name
}

output "gcp_storage_url" {
    description = "The Google Storage Bucket's URL which is provisioned on GCP"
    value = module.storage.storage_url
}

output "gcp_storage_service_account" {
    description = "The Google Service Account's email after created GCS"
    value = module.storage.service_account
}