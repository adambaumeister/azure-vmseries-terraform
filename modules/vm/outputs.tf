output "resource-group" {
  value = azurerm_resource_group.vmseries
}

output "ip" {
  value = azurerm_public_ip.pip-fw-mgmt.ip_address
}

output "inside-ip" {
  value = azurerm_network_interface.nic-fw-inside.private_ip_address
}

output "outside-ip" {
  value = azurerm_network_interface.nic-fw-outside.private_ip_address
}

# The nic that sits on the "outside" or "external" network
output "outside-nic" {
  value = azurerm_network_interface.nic-fw-outside
}

# The nic that sits on the "inside" or "internal" network
output "inside-nic" {
  value = azurerm_network_interface.nic-fw-inside
}

