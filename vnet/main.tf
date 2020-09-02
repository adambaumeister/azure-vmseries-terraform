# Configure the Azure Provider
provider "azurerm" {
   version = "=2.20.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg1" {
  name     = "pstajewski-rg1"
  location = "Australia Southeast"
}

#Create management network security group
resource "azurerm_network_security_group" "nsg1" {
  name                = "{var.rg1}-{var.vnet1}-mgmt-nsg"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

#Create VNET and subnets
resource "azurerm_virtual_network" "vnet1" {
  name                = "pstajewski-vnet1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.1.1.0/16"]
#  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "management-subnet"
    address_prefix = "10.1.0.0/24"
	security_group = azurerm_network_security_group.nsg1.id
  }

  subnet {
    name           = "untrust-subnet"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "trust-subnet"
    address_prefix = "10.1.2.0/24"
  }
  subnet {
  name           = "appgw-subnet"
  address_prefix = "10.1.254.0/24"
  }

  tags = {
    environment = "Production"
  }
}