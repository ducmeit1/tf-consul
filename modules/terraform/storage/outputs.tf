output "storage_name" {
    description = "The storage name for google storage bucket after provision"
    value = google_storage_bucket.iac-terraform-state-bucket.name
}

output "storage_url" {
    description = "The storage url for google storage bucket after provision"
    value = google_storage_bucket.iac-terraform-state-bucket.url
}

output "service_account" {
    description = "The email for the service account created for the bastion host"
    value = google_service_account.iac-terraform-state-bucket.email
}