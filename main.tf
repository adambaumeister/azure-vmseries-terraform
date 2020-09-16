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
  olb-ip = var.olb-private-ip
}

# Create a panorama instance
module "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
  subnet-mgmt = module.networks.panorama-mgmt-subnet

  username = var.username
  password = var.password
}

# Create the INBOUND vm-series
module "vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = var.name_prefix
  username = var.username
  password = var.password

  subnet-mgmt = module.networks.subnet-mgmt
  subnet-private = module.networks.subnet-private
  subnet-public = module.networks.subnet-public

  bootstrap-storage-account = module.panorama.bootstrap-storage-account
  bootstrap-share-name = module.panorama.inbound-bootstrap-share-name

  depends_on = [module.panorama]
}

# Create the OUTBOUND vm-series
module "outbound-vm-series" {
  source = "./modules/vm"

  location = var.location
  name_prefix = "${var.name_prefix}-outbound"
  username = var.username
  password = var.password

  subnet-mgmt = module.networks.subnet-mgmt
  subnet-private = module.networks.subnet-private
  subnet-public = module.networks.subnet-public

  bootstrap-storage-account = module.panorama.bootstrap-storage-account
  bootstrap-share-name = module.panorama.outbound-bootstrap-share-name
  depends_on = [module.panorama]
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
    module.outbound-vm-series.inside-nic
  ])
  private-ip = var.olb-private-ip
  backend-subnet = module.networks.subnet-private.id
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

output "storage-key" {
  value = module.panorama.storage-key
}