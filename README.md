# Active Directory quick start

Quickly deploy an Active Directory test environment with Terraform.

Forest creation and member server join are both automated.

Makes use of [azurecaf provider](https://github.com/aztfmod/terraform-provider-azurecaf) `aztfmod/azurecaf` for generating CAF-compliant resource names.

## Example usage

`terraform apply -var-file="_dev.tfvars" -auto-approve`