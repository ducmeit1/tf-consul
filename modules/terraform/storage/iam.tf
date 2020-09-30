locals {
    bucketRoles = [
        "roles/storage.legacyObjectReader",
        "roles/storage.legacyBucketWriter"
    ]
}

resource "google_service_account" "iac-terraform-state-bucket" {
    project = var.project
    account_id = "iac-terraform-state-bucket"
    display_name = "Service account for terraform state bucket"
}

resource "google_storage_bucket_iam_member" "iac-terraform-state-bucket-roles" {
    for_each = toset(local.bucketRoles)
    bucket = google_storage_bucket.iac-terraform-state-bucket.name
    role = each.value
    member = format("serviceAccount:%s", google_service_account.iac-terraform-state-bucket.email)
}