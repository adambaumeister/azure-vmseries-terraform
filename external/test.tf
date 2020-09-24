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
    "121.45.210.83" : 100
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
  olb-ip         = var.olb-private-ip
}
# Create a panorama instance
module "panorama" {
  source = "../modules/panorama"

  location    = var.location
  name_prefix = var.name_prefix
  subnet-mgmt = module.networks.panorama-mgmt-subnet
  password    = "NicePassword!"
}

data "external" "panorama_bootstrap" {
  depends_on = [module.panorama]
  program    = ["python", "${path.module}/configure_panorama.py"]
  query = {
    panorama_ip                 = module.panorama.panorama-publicip
    username                    = "panadmin"
    password                    = "NicePassword!"
    storage_account_name        = module.panorama.bootstrap-storage-account.name
    storage_account_key         = module.panorama.bootstrap-storage-account.primary_access_key
    inbound_storage_share_name  = module.panorama.inbound-bootstrap-share-name
    outbound_storage_share_name = module.panorama.outbound-bootstrap-share-name
    key_lifetime                = var.key_lifetime
  }
}
output "vm-auth-key" {
  value = data.external.panorama_bootstrap.result.vm-auth-key
}