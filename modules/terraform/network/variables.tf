variable "project" {
    type = string
}

variable "region" {
    type = string
}

variable "network_name" {
    type = string
}

variable "subnetwork_name" {
    type = string
}

variable "nat_subnetwork_names" {
    type = list(string)
}

variable "ip_cidr_range" {
    type = string
    default = "10.127.0.0/20"
}

variable "total_nat_ips" {
    type = number
    default = 2
}