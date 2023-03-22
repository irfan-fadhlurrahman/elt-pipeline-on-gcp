#!/bin/bash

echo "Exporting Terraform variables to Shell session."
sleep 3
source "../.env"

export TF_VAR_project_id="${GCP_PROJECT_ID}" 
export TF_VAR_credentials="${GCP_CREDENTIALS}" 
export TF_VAR_region="${GCP_REGION}" 
export TF_VAR_zone="${GCP_ZONE}"
export TF_VAR_dataset_name="${DATASET_NAME}"
export TF_VAR_dataset_location="${DATASET_LOCATION}"

echo "Run All Resources"
sleep 2
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply -auto-approve
# terraform destroy -auto-approve
