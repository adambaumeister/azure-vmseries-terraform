output "vnet" {
  value = azurerm_virtual_network.vnet-vmseries
}

output "resource-group" {
  value = azurerm_resource_group.vmseries
}

output "ip" {
  value = azurerm_public_ip.pip-fw-mgmt.ip_address
}