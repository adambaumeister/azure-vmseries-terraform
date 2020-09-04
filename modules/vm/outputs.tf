output "vnet" {
  value = azurerm_virtual_network.vnet-vmseries
}

output "resource-group" {
  value = azurerm_resource_group.vmseries
}

output "ip" {
  value = azurerm_public_ip.pip-fw-mgmt.ip_address
}

output "subnet-mgmt" {
  value = azurerm_subnet.subnet-mgmt
}

output "mgmt-nsg" {
  value = azurerm_network_security_group.sg-mgmt
}