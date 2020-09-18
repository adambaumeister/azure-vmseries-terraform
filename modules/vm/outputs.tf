output "resource-group" {
  value = azurerm_resource_group.vmseries
}

output "ip" {
  value = azurerm_public_ip.pip-fw-mgmt.ip_address
}

output "inside-ip" {
  value = azurerm_network_interface.nic-fw-private.private_ip_address
}

output "outside-ip" {
  value = azurerm_network_interface.nic-fw-public.private_ip_address
}

# The nic that sits on the "outside" or "external" network
output "public-nic" {
  value = azurerm_network_interface.nic-fw-public
}

# The nic that sits on the "inside" or "internal" network
output "private-nic" {
  value = azurerm_network_interface.nic-fw-private
}

