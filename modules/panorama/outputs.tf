output "vnet-name" {
  value = azurerm_virtual_network.vnet-mgmt.name
}

output "vnet-id" {
  value = azurerm_virtual_network.vnet-mgmt.id
}

output "vnet" {
  value = azurerm_virtual_network.vnet-mgmt
}

output "panorama-publicip" {
  value = azurerm_public_ip.panorama-pip-mgmt.ip_address
}