# Consul IaC with Terraform on GCP

## Introduction

- This Terraform will helps deploy Consul cluster on GCP
- The repository includes:
  - Create a private VPC
  - Create bastion host with GCP Compute VN
  - Create consul cluster with GCP Compute VM
  - Create service account
  - Create firewall

## Prerequisites

- A GCP Account & Project
- Terraform CLI >= 12.26
- GCloud CLI

## Guidelines

- Create a `terraform.tfvars` file which is contains value of global variable includes:
  - GCP Project ID
  - GCP Region
  - GCP Zone
  - Members assign to the Google Service Account for allowing ssh access

Example:

```
region  = "asia-east1"
project = "driven-stage-xxx"
zone    = "asia-east1-c"
members = ["user:your-email@gmail.com"]
```

### Google Service Account Credentials

Get credentials of your GSA (Google Service Account) from `gcloud` CLI and save to JSON format with file name `credentials.json` by steps:

- Login to GCP by gcloud: 
  ```
  gcloud auth login
  ```
  
- List the GCP project are available: 
  ```
  gcloud projects list
  ```
  
- Set your project ID by: 
  ```
  gcloud config set project your-project-id
  ```
  
- List the service accounts avaiable: 
  ```
  gcloud iam service-accounts list
  ```
  
- Create a new service account key by: 
  ```
  gcloud iam service-accounts keys create credentials.json --iam-account=the-service-account-name@project-id.iam.gserviceaccount.com
  ```

### Run with Terraform

- Validate: `terraform validate`

- Plan: `terraform plan`

- Apply: `terraform apply` or `terraform apply --auto-approve`