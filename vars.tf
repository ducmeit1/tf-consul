variable "project" {
  description = "The project id of GCP"
}

variable "region" {
  description = "The region to provision on GCP"
  default = "asia-east1"
}

variable "zone" {
  description = "The zone of region to provision on GCP"
  default = "asia-east1-c"
}

variable "members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email}"
  default     = []
}