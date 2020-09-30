locals {
    consulRoles = [
        "roles/iam.serviceAccountUser"
    ]
}

resource "google_service_account" "consul-cluster" {
    project = var.gcp_project_id
    account_id = format("%s-consul-cluster", var.cluster_name)
    display_name = "Service account for consul cluster"
}

resource "google_service_account_iam_member" "consul-cluster-sa" {
    service_account_id = google_service_account.consul-cluster.id
    for_each = toset(local.consulRoles)
    role = each.value
    member = format("serviceAccount:%s", google_service_account.consul-cluster.email)
}