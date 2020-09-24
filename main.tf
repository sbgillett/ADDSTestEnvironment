# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>0.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.5.0"
    }

  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "random_string" "alpha1" {
  length  = 1
  special = false
  upper   = false
  number  = false
}


locals {
  local_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
  tags = merge(var.tags, local.local_tags)

  global_settings = {
    suffix           = local.suffix
    convention       = var.convention
    default_location = var.location
    environment      = var.environment
  }

  prefix             = var.prefix
  prefix_with_hyphen = var.prefix == "" ? "" : "${local.prefix}-"

  suffix             = var.suffix == null ? random_string.suffix.result : var.suffix
  suffix_with_hyphen = "-${local.suffix}"
}