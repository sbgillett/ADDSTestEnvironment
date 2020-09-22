Quickly deploy an Active Directory test environment with Terraform

This version uses a Powershell script to create the root forest and DC.

`terraform apply -var-file="_dev.tfvars" -auto-approve`