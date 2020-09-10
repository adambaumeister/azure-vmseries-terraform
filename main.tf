# Configure the Azure provider
terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~>1.32.0"
    }
  }
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

# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "./modules/lbs"

  location = var.location
  name_prefix = var.name_prefix
  rules = var.rules
  backend-nics = toset([
        module.vm-series.outside-nic
  ])
}

# Deploy the outbound load balancer for traffic out of the azure environment
module "outbound-lb" {
  source = "./modules/olb"
  location = var.location
  name_prefix = var.name_prefix
  backend-nics = toset([
    module.vm-series.inside-nic
  ])
  private-ip = var.olb-private-ip
  backend-subnet = module.vm-series.inside-subnet.id
}

module "onboard-test-vnet" {
  source = "./modules/onboard-vnet"
  lb-ip = var.olb-private-ip
  remote-vnet = module.test-host.vnet
  remote-subnet = module.test-host.subnet
  location = var.location
  name_prefix = var.name_prefix
}

# Create a test-host for validation
module "test-host" {
  source = "./modules/test-vnet"
  location = var.location
  name_prefix = var.name_prefix
  peer-vnet = module.vm-series.vnet
  admin-password = var.admin-password
  route-table-id = module.onboard-test-vnet.route-table-id
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