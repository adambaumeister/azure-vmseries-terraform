# Configure the Azure provider
terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~>1.32.0"
    }
  }
}

# Setup all the networks required for the topology
module "networks" {
  source = "./modules/networks"
  location = var.location
  management_ips = var.management_ips
  name_prefix = var.name_prefix

  management_vnet_prefix = var.management_vnet_prefix
  management_subnet = var.management_subnet

  olb_private_ip = var.olb_private_ip

  firewall_vnet_prefix = var.firewall_vnet_prefix
  private_subnet = var.private_subnet
  public_subnet = var.public_subnet
  vm_management_subnet = var.vm_management_subnet
}

# Create a panorama instance
module "panorama" {
  source = "./modules/panorama"

  location = var.location
  name_prefix = var.name_prefix
  subnet_mgmt = module.networks.panorama-mgmt-subnet

  username = var.username
  password = var.password

  panorama_sku = var.panorama_sku
  panorama_version = var.panorama_version
}

# Create the INBOUND vm-series
module "inbound-vm-series" {
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

  vm_series_count = 2
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
        module.inbound-vm-series.public-nic
  ])
}

# Deploy the outbound load balancer for traffic out of the azure environment
module "outbound-lb" {
  source = "./modules/olb"
  location = var.location
  name_prefix = var.name_prefix
  backend-nics = toset([
    module.outbound-vm-series.private-nic
  ])
  private-ip = var.olb_private_ip
  backend-subnet = module.networks.subnet-private.id
}

output "PANORAMA-IP" {
  value = module.panorama.panorama-publicip
}
