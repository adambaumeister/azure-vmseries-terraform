output "vnet-name" {
  value = azurerm_virtual_network.vnet-mgmt.name
}

output "vnet-id" {
  value = azurerm_virtual_network.vnet-mgmt.id
}

output "vnet" {
  value = azurerm_virtual_network.vnet-mgmt
}

output "subnet-mgmt" {
  value = azurerm_subnet.subnet-mgmt
}

output "panorama-publicip" {
  value = azurerm_public_ip.panorama-pip-mgmt.ip_address
}

output "resource-group" {
  value = azurerm_resource_group.panorama
}

output "nsg" {
  value = azurerm_network_security_group.sg-mgmt
}