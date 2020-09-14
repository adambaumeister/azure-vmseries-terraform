resource "azurerm_resource_group" "rg" {
  location = var.location
  name = "${var.name_prefix}-rg-networks"
}
### Build the Panorama networks first
# Create the out of band network for panorama
resource "azurerm_virtual_network" "vnet-panorama-mgmt" {
  address_space = ["10.10.10.0/24"]
  location = var.location
  name = "${var.name_prefix}-vnet-panorama-mgmt"
  resource_group_name = azurerm_resource_group.rg.name
}
# Security group for the Panorama MGMT network
resource "azurerm_network_security_group" "sg-panorama-mgmt" {
  location = azurerm_resource_group.rg.location
  name = "${var.name_prefix}-sg-panorama-mgmt"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "panorama-mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-panorama-mgmt.id
  subnet_id = azurerm_subnet.subnet-panorama-mgmt.id
}
resource "azurerm_subnet" "subnet-panorama-mgmt" {
  name = "${var.name_prefix}-net-panorama-mgmt"
  address_prefix = "10.10.10.0/26"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-panorama-mgmt.name
  network_security_group_id = azurerm_network_security_group.sg-panorama-mgmt.id
}

### Now build the main networks
resource "azurerm_virtual_network" "vnet-vmseries" {
  address_space = ["172.16.0.0/16"]
  location = azurerm_resource_group.rg.location
  name = "${var.name_prefix}-vnet-vmseries"
  resource_group_name = azurerm_resource_group.rg.name
}
# Management for VM-series
resource "azurerm_subnet" "subnet-mgmt" {
  name = "${var.name_prefix}-net-vmseries-mgmt"
  address_prefix = "172.16.0.0/24"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
  network_security_group_id = azurerm_network_security_group.sg-mgmt.id

}
resource "azurerm_network_security_group" "sg-mgmt" {
  location = azurerm_resource_group.rg.location
  name = "${var.name_prefix}-sg-vmmgmt"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-mgmt.id
  subnet_id = azurerm_subnet.subnet-mgmt.id
}

# private network - don't need NSG here?
resource "azurerm_subnet" "subnet-inside" {
  name = "${var.name_prefix}-net-inside"
  address_prefix = "172.16.1.0/24"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}

# Public network
resource "azurerm_network_security_group" "sg-outside" {
  location = azurerm_resource_group.rg.location
  name = "${var.name_prefix}-sg-outside"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet-outside" {
  name = "${var.name_prefix}-net-outside"
  address_prefix = "172.16.2.0/24"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name =  azurerm_virtual_network.vnet-vmseries.name
  network_security_group_id = azurerm_network_security_group.sg-outside.id
}
resource "azurerm_subnet_network_security_group_association" "sg-outside-associate" {
  network_security_group_id = azurerm_network_security_group.sg-outside.id
  subnet_id = azurerm_subnet.subnet-outside.id
}

# Peer the VNETs from the vm-series and panorama module
resource "azurerm_virtual_network_peering" "panorama-fw-peer" {
  name = "${var.name_prefix}-mgmt-peering"
  remote_virtual_network_id = azurerm_virtual_network.vnet-panorama-mgmt.id
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}
resource "azurerm_virtual_network_peering" "fw-panorama-peer" {
  name = "${var.name_prefix}-mgmt-peering-r"
  remote_virtual_network_id = azurerm_virtual_network.vnet-vmseries.id
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-panorama-mgmt.name
}

