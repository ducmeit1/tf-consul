variable "project" {
  type = string
  description = "The project id to provision on GCP"
}

variable "region" {
  type = string
  description = "The region to provision on GCP"
}

variable "zone" {
  type = string
  description = "The zone of region to provision on GCP"
}

variable "network_name" {
  type = string
  description = "The name's network to provision on GCP"
}

variable "subnetwork_name" {
  type = string
  description = "The name's subnetwork to provision on GCP"
}

variable "storage_location" {
  type = string
  description = "The location of GCS on GCP"
  default = null
}

variable "members" {
  type = list(string)
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email}"
  default     = []
}