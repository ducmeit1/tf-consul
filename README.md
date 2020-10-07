# Provision Consul Cluster on GCP with Terraform

This module help you deploy a consul cluster with managed instance group on GCP with Terraform.

This module will:

- Create a instance template
- Create a instance group with created instance template
- Create firewalls
- Create a custom role to allow use auto cloud cluster join

## Usages

- You could uses a base image and install Consul by Ansible Playbook, or hand manually. Optional, you could use Packer to package a image have installed Consul. (You could refer to: [packer-consul-gcp](https://github.com/ducmeit1/packer-consul-gcp))

> **Attentions**: There are two ways to set image for instance template, you could use your own image, or base image on GCP. To use base image, please define family_image and project_image_id as example below. Otherwise, you must set image by use source_image.

```hcl
module "consul-server" {
  source = "github.com/ducmeit1/tf-consul-gcp"

  gcp_project                             = "driven-stage-269911"
  gcp_region                              = "asia-southeast1"
  gcp_network                             = "my-network"
  gcp_subnetwork                          = "my-subnetwork"
  cluster_name                            = "consul-dc1-gcp"
  cluster_tag_name                        = "consul-dc1-gcp"
  cluster_size                            = 3
  cluster_description                     = "consul cluster dc1 on gcp"
  custom_tags                             = ["dc1", "gcp"]
  machine_type                            = "n1-standard-1"
  family_image                            = "debian-9"
  image_project_id                        = "debian-cloud"
  startup_script                          = "gs://my-gcs-bucket/scripts/startup-script.sh"
  shutdown_script                         = "gs://my-gcs-bucket/scripts/shutdown-script.sh"
  root_volume_disk_size_gb                = 30
  root_volume_disk_type                   = "pd-ssd"
  allowed_inbound_cidr_blocks_http_api    = ["10.126.0.0/20"]
  allowed_inbound_tags_http_api           = ["consul-client"]
  
}
```
