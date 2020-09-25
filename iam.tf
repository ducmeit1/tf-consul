resource "google_service_account" "consul-cluster" {
    project = var.project
    account_id = "consul-cluster"
    display_name = "Service account for consul cluster"
}

resource "google_service_account_iam_member" "consul-cluster-sa" {
    service_account_id = google_service_account.consul-cluster.id
    role = "roles/iam.serviceAccountUser"
    for_each = toset(var.members)
    member = each.value
}
