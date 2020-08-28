# Base resource group
resource "azurerm_resource_group" "panorama" {
  location = var.location
  name = "${var.name_prefix}-rg-panorama"
}

# Create the out of band network
resource "azurerm_virtual_network" "vnet-mgmt" {
  address_space = ["10.10.10.0/24"]
  location = var.location
  name = "${var.name_prefix}-vnet-mgmt"
  resource_group_name = azurerm_resource_group.panorama.name
}