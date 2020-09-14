# Configure the Azure provider
terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~>1.32.0"
    }
  }
}

# Setup all the networking
module "networks" {
  source = "./modules/networks"
  location = var.location
  management_ips = var.management_ips
  name_prefix = var.name_prefix
}
# Create a panorama instance
module  "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
  subnet-mgmt = module.networks.panorama-mgmt-subnet
}

# create a vm-series fw
module "vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = var.name_prefix
  subnet-mgmt = module.networks.subnet-mgmt
  subnet-private = module.networks.subnet-private
  subnet-public = module.networks.subnet-public
  bootstrap-storage-account = module.panorama.bootstrap-storage-account

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
  backend-subnet = module.networks.subnet-private.id
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
  peer-vnet = module.networks.transit-vnet
  admin-password = var.admin-password
  route-table-id = module.onboard-test-vnet.route-table-id
}


output "PANORAMA-IP" {
  value = module.panorama.panorama-publicip
}

output "VM-IP" {
  value = module.vm-series.ip
}

output "Inbound-PIPS" {
  value = module.inbound-lb.pip-ips
}