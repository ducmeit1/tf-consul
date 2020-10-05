# Sample Consul Cluster with Terraform

This sample will:

- Create a private network includes a sub-network and a NAT by (Cloud-NAT).
  
- Create a bastion host to allow you to secure your private network and ssh via IAP by tunneling.

- Create a private google cloud storage to store terraform state on GCP.

- Create instance templates as well as managed instance groups on GCP for Consul Server Cluster and Consul Client Cluster.

## Usages

- You could set value of variables in locals

- You could read these terraform modules to customize more configuration:

    - [Network Module](https://github.com/ducmeit1/tf-network-gcp)
    - [Bastion Module](https://github.com/ducmeit1/tf-bastion-gcp)
    - [Storage Module](https://github.com/ducmeit1/tf-storage-gcp)

- You must create image by Packer & Ansible first before uses this module, set image for Server at variable `consul_server_source_image`, and for Client at variable `consul_client_source_image`

- Use a GSA (Google Service Account) credentials with named `credentials.json` to provision with this module.

- In case, you want use terraform local state, please remove the backend in `terraform` block.
  
  ```hcl
  terraform {
    required_version = ">= 0.12"
  }
  ```

- Otherwises, you must provision storage module first before uses it as backend.

```shell
terraform init
terraform plan
terraform apply --auto-approve
```