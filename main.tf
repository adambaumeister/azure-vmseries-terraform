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
variable "rules" {
  type = list(object({
    port = number
    nat_ip = string
  }))
}

variable "management_ips" {
  type = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network"
}

# Create a panorama instance
module  "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
  management_ips = var.management_ips
}

# create a vm-series fw
module "vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = var.name_prefix
  management_ips = var.management_ips

}

# create a vm-series fw
module "inbound-lb" {
  source = "./modules/lbs"

  location = var.location
  name_prefix = var.name_prefix
  rules = var.rules
  backend-nics = toset([
        module.vm-series.outside-nic
  ])
}

output "MGMT-VNET" {
  value = module.panorama.vnet-name
}

output "PANORAMA-IP" {
  value = module.panorama.panorama-publicip
}

output "VM-IP" {
  value = module.vm-series.ip
}