# Peer the VNETs from the vm-series and panorama module
resource "azurerm_virtual_network_peering" "panorama-fw-peer" {
  name = "${var.name_prefix}-mgmt-peering"
  remote_virtual_network_id = module.panorama.vnet.id
  resource_group_name = module.vm-series.resource-group.name
  virtual_network_name = module.vm-series.vnet.name
}
