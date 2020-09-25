provider "google" {
  project     = var.project
  region      = var.region
  version     = "~> 3.26"
  credentials = file("credentials.json")
  zone        = var.zone
}