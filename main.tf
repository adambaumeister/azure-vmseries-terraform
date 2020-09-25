# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.20.0"
  features {}
}


# Setup all the networks required for the topology
module "networks" {
  source         = "./modules/networks"
  location       = var.location
  management_ips = var.management_ips
  name_prefix    = var.name_prefix

  management_vnet_prefix = var.management_vnet_prefix
  management_subnet      = var.management_subnet

  olb_private_ip = var.olb_private_ip

  firewall_vnet_prefix = var.firewall_vnet_prefix
  private_subnet       = var.private_subnet
  public_subnet        = var.public_subnet
  vm_management_subnet = var.vm_management_subnet
}

# Create a panorama instance
module "panorama" {
  source = "./modules/panorama"

  location    = var.location
  name_prefix = var.name_prefix
  subnet_mgmt = module.networks.panorama-mgmt-subnet

  username = var.username
  password = var.password

  panorama_sku     = var.panorama_sku
  panorama_version = var.panorama_version
}

# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "./modules/lbs"

  location    = var.location
  name_prefix = var.name_prefix
  rules       = var.rules

}

# Deploy the outbound load balancer for traffic out of the azure environment
module "outbound-lb" {
  source         = "./modules/olb"
  location       = var.location
  name_prefix    = var.name_prefix
  private-ip     = var.olb_private_ip
  backend-subnet = module.networks.subnet-private.id
}


# Create the inbound and outbound VM Scale sets
module "vm-series" {
  source = "./modules/vmss"

  location    = var.location
  name_prefix = var.name_prefix
  username    = var.username
  password    = var.password

  subnet-mgmt    = module.networks.subnet-mgmt
  subnet-private = module.networks.subnet-private
  subnet-public  = module.networks.subnet-public

  bootstrap-storage-account     = module.panorama.bootstrap-storage-account
  inbound-bootstrap-share-name  = module.panorama.inbound-bootstrap-share-name
  outbound-bootstrap-share-name = module.panorama.outbound-bootstrap-share-name

  depends_on = [module.panorama]

  vhd-container           = module.panorama.storage-container-name
  private_backend_pool_id = module.outbound-lb.backend-pool-id
  public_backend_pool_id  = module.inbound-lb.backend-pool-id
}

# Create a test VNET
module "test-host" {
  source         = "./modules/test-vnet"
  admin-password = var.password
  location       = var.location
  name_prefix    = var.name_prefix
  peer-vnet      = module.networks.transit-vnet
  route-table-id = module.networks.outbound-route-table
}


output "PANORAMA-IP" {
  value = module.panorama.panorama-publicip
}
