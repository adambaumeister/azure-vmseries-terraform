locals {
  bootstrap-share-name = "bootstrapshare"
}

# The storage account is used for the VM Series bootstrap
# Ref: https://docs.paloaltonetworks.com/vm-series/8-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6
resource "azurerm_storage_account" "bootstrap-storage-account" {
  location = var.location
  name = local.bootstrap-share-name
  account_replication_type = "LRS"
  account_tier = "Standard"
  resource_group_name = azurerm_resource_group.panorama.name
}

# Create rhe share to house the directories
### INBOUND ####
resource "azurerm_storage_share" "inbound-bootstrap-storage-share" {
  name = "ibbootstrapshare"
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota = 50
}

resource "azurerm_storage_share_directory" "bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
    "license"])
  name = each.key
  share_name = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "inbound-bootstrap-config-directory" {
  share_name = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  name = "config"
}

#
#### OUTBOUND #####
#
resource "azurerm_storage_share" "outbound-bootstrap-storage-share" {
  name = "obbootstrapshare"
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota = 50
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
    "license"])
  name = each.key
  share_name = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-config-directory" {
  share_name = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  name = "config"
}

data "external" "panorama_bootstrap" {
  # This datasource retrieves the vm-auth-key using a custom compiled python script
  # It then compiles that - and the other provided params - into the rendered bootstrap init-cfg files.
  depends_on = [azurerm_virtual_machine.panorama]
  program = ["${path.module}/configure_panorama.exe"]
  query = {
    panorama_ip = azurerm_public_ip.panorama-pip-mgmt.ip_address
    username = var.username
    password = var.password
    panorama_private_ip = azurerm_network_interface.mgmt.private_ip_address
    storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
    storage_account_key = azurerm_storage_account.bootstrap-storage-account.primary_access_key
    inbound_storage_share_name = azurerm_storage_share.inbound-bootstrap-storage-share.name
    outbound_storage_share_name = azurerm_storage_share.outbound-bootstrap-storage-share.name
    key_lifetime  = var.bootstrap_key_lifetime
    output_dir    = path.module
  }
}
