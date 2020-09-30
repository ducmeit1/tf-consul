variable "project" {
    type = string
}

variable "region" {
    type = string
}

variable "zone" {
    type = string
}

variable "network_url" {
    type = string
}

variable "subnetwork_url" {
    type = string
}

variable "network_name" {
    type = string
}

variable "subnetwork_name" {
    type = string
}

variable "members" {
  type = list(string)
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email}"
  default     = []
}

variable "machine_type" {
    type = string
    default = "g1-small"
}

variable "source_tags" {
    type = list(string)
    default = ["bastion"]
}

variable "target_tags" {
    type = list(string)
    default = ["bastion-access"]
}

variable "disk_size_gb" {
    type = number
    default = 10
}

variable "image_family" {
    type = string
    default = "ubuntu-1804-lts"
}

variable "target_ports" {
    type = list(string)
    default = ["22", "80", "443", "8888"]
}