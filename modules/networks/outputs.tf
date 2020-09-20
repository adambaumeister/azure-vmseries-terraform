output "subnet-mgmt" {
  value = azurerm_subnet.subnet-mgmt
}
output "subnet-public" {
  value = azurerm_subnet.subnet-outside
}
output "subnet-private" {
  value = azurerm_subnet.subnet-inside
}
output "transit-vnet" {
  value = azurerm_virtual_network.vnet-vmseries
}
output "vm-mgmt" {
  value = azurerm_virtual_network.vnet-vmseries
}
output "panorama-mgmt-subnet" {
  value = azurerm_subnet.subnet-panorama-mgmt
}

output "outbound-route-table" {
  value = azurerm_route_table.udr-inside.id
}