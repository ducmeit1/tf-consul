terraform {
    required_version = ">= 0.12"
}

resource "google_storage_bucket" "iac-terraform-state-bucket" {
    project = var.project
    name = "iac-terraform-state-bucket"
    location = var.location
    force_destroy = false
    
    labels = {
        creator = "terraform"
    }

    versioning {
        enabled = "true"
    }

    lifecycle_rule {
        action {
            type = "SetStorageClass"
            storage_class = "NEARLINE"
        }

        condition {
            age = "7"
            with_state = "ANY"
        }
    }

    lifecycle_rule {
        action {
            type = "Delete"
        }

        condition {
            age = "31"
            matches_storage_class = ["NEARLINE"]
            num_newer_versions = "3"
        }
    }
}

resource "google_storage_bucket_acl" "iac-terraform-state-bucket-acl" {
    bucket = google_storage_bucket.iac-terraform-state-bucket.name
    predefined_acl = "private"
}