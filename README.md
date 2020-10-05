# Deploy Consul Server/Client Cluster on GCP with Terraform

## Introduction

- This module will:
  - Create instance template from existed image
  - Create managed instance group from instance template
  - Create image by Packer & Ansible

## Prerequisites

- GCloud
- Ansible >= 2.9
- Packer >= 1.8.3
  
## Usages

### TL;DR

- Refer to the examples code in `examples/consul-cluster` to understand how to uses this module with sample code.

- Build Image with Packer:

```shell
cd modules/packer
packer build consul-server.json
packer build consul-client.json
```

Copy the Image Name was returned by Packer

- Create gossip encryption key:

```shell
consul keygen
```

- Create TLS

Create CA Certificate

```shell
cd modules/packer/tls/ca
consul tls ca create
```

Create Server Certificate

```shell
cd modules/packer/tls/server
consul tls cert create -server
```

If you have own CA Ceritificate, you could create certificate by uses:

```shell
cd modules/packer/tls/server
consul tls cert server -server -ca-file your-ca.pem -ca-key-file -your-ca-key.pem
```

Create Client Certificate

```shell
cd modules/packer/tls/client
consul tls cert create -client
```

- Change gossip encryption key in `modules/ansible/consul/defaults` at `consul_gossip_encryption_key` variable.

- You could change templates of startup or shutdown script at: `modules/ansible/consul/templates`

### Uses Packer

- Packer uses to create GCP Image for instance template, please uses the configuration in `modules/packer`. There are two configurations for client and server with includes optional TLS (but recommendation to using). You could test the cluster with the TLS was created in `modules/packer/tls`. Or using `consul tls` to create TLS (Self-signed).

- The require variables must to change:
  - project_id: GCP Project ID (must change)
  - zone: GCP Zone (asia-southeast1-c is default)
  - consul_version: Version of Consul (1.8.4 is default)
  - gcp_account_file: The credentials file of GSA (Google Service Account), default is `credentials.json` which is located at `modules/packer/credentials.json`

- Uses `packer build consul-server.json` to build Consul Server and `packer build consul-client.json` to build Consul Client.

- By the way, you could uses:

```shell
packer build \
  - var 'project_id=your-project-id' \
  - var 'zone=gcp-zone' \
  - var 'consul_version=1.8.4' \
  - var 'gcp_account_file={{template_dir}}/credentials.json' \
  consul-server.json
```

> Note: {{template_dir}} will return the working directiry of packer configuration, for example `modules/packer/credentials.json`

### Uses Ansible

- Packer requires Ansible to run scripts, you could read playbook at `modules/ansible`
- There are two roles will be installed: `consul` and `dnsmaq`
- Please read and configure value of variables in `defaults`

### Run Terraform

```shell
terraform plan
terraform apply --auto-approve
```

## Consul Features

- [Cloud Auto-join](https://www.consul.io/docs/install/cloud-auto-join) on GCP.
  
- [Consul Connect](https://www.consul.io/docs/connect) - Service Mesh.
  
- [Consul Encryption](https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure) with Gossip Encryption Key and TLS.

- [Consul WAN Federation](https://www.consul.io/docs/connect/gateways/mesh-gateway/wan-federation-via-mesh-gateways) via Mesh Gateways.

- [Consul DNS](https://learn.hashicorp.com/tutorials/consul/dns-forwarding)