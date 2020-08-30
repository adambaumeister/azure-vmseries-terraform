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

variable "management_ips" {
  type = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network"
}

module "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
  management_ips = var.management_ips
}

module "vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = var.name_prefix
}

output "MGMT-VNET" {
  value = module.panorama.vnet-name
}

output "PANORAMA-IP" {
  value = module.panorama.panorama-publicip
}