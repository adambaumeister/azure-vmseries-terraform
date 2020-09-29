terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~>1.32.0"
    }
  }
}

variable "key_lifetime" {
  type    = string
  default = "8760"
}
variable "location" {
  type        = string
  description = "The Azure region to use."
  default     = "Australia Central"
}
variable "name_prefix" {
  type        = string
  description = "A prefix for all naming conventions - used globally"
  default     = "pantf"
}
variable "management_ips" {
  type        = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network"
  default = {
    "203.214.46.154" : 100
  }
}

variable "olb-private-ip" {
  # This IP MUST be in the same subnet as the firewall "internal" interfaces
  description = "The private IP address to assign to the Outgoing Load balancer frontend"
  default     = "172.16.1.250"
}

# Setup all the networking
module "networks" {
  source         = "../modules/networks"
  location       = var.location
  management_ips = var.management_ips
  name_prefix    = var.name_prefix
  olb_private_ip = var.olb-private-ip
}
# Create a panorama instance
module "panorama" {
  source = "../modules/panorama"

  location    = var.location
  name_prefix = var.name_prefix
  password    = "NicePassword!"
  subnet_mgmt = module.networks.panorama-mgmt-subnet
}

output "sak" {
  value = "-sn ${module.panorama.bootstrap-storage-account.name} -sk ${module.panorama.bootstrap-storage-account.primary_access_key}"
}

output "share-names" {
  value = "-iss ${module.panorama.inbound-bootstrap-share-name} -oss ${module.panorama.outbound-bootstrap-share-name}"
}

output "panorama-pp" {
  value = "-pp ${module.panorama.panorama-publicip}"
}