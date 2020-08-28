# Configure the Azure provider
terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~>1.32.0"
    }
  }
}

# Setup the variables we need...
variable "location" {
  type = string
  description = "The Azure region to use."
  default = "Australia Central"
}
variable "name_prefix" {
  type = string
  description = "A prefix for all naming conventions - used globally"
  default = "pantf"
}

module "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
}

module "vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = var.name_prefix
}

output "MGMT-VNET" {
  value = module.panorama.vnet-name
}