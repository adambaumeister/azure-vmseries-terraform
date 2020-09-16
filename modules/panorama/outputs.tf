
output "panorama-publicip" {
  value = azurerm_public_ip.panorama-pip-mgmt.ip_address
}

output "resource-group" {
  value = azurerm_resource_group.panorama
}

output "bootstrap-storage-account" {
  value = azurerm_storage_account.bootstrap-storage-account
}

output "inbound-bootstrap-share-name" {
  value = azurerm_storage_share.inbound-bootstrap-storage-share.name
}

output "outbound-bootstrap-share-name" {
  value = azurerm_storage_share.outbound-bootstrap-storage-share.name
}

output "storage-key" {
  value = azurerm_storage_account.bootstrap-storage-account.primary_access_key
}
