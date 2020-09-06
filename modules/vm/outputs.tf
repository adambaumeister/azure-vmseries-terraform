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

output "inside-ip" {
  value = azurerm_network_interface.nic-fw-inside.private_ip_address
}

output "outside-ip" {
  value = azurerm_network_interface.nic-fw-outside.private_ip_address
}

output "outside-nic" {
  //value = azurerm_network_interface.nic-fw-outside.ip_configuration[0].name
  value = azurerm_network_interface.nic-fw-outside
}