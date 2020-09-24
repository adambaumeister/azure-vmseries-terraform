output "vm-public-nic" {
  value = azurerm_network_interface.nic-fw-public.id
}

output "vm-private-nic" {
  value = azurerm_network_interface.nic-fw-private.id
}