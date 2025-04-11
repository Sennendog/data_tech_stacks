# How to execute/deploy this project

## Setup Service Account permissions for terraform
    cd 00_prepare_gcp_serviceaccount
    Linux: ./gcp-prepapre.sh
    Windows: ./gcp-prepapre.ps1

## Setup infrastructure (terraform)
    cd 01_infrastructure
    terraform init  # first time only
    terraform plan -var-file="env_dev.tfvars"
    terraform apply -var-file="env_dev.tfvars"

