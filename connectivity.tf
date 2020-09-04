# Peer the VNETs from the vm-series and panorama module
resource "azurerm_virtual_network_peering" "panorama-fw-peer" {
  name = "${var.name_prefix}-mgmt-peering"
  remote_virtual_network_id = module.panorama.vnet.id
  resource_group_name = module.vm-series.resource-group.name
  virtual_network_name = module.vm-series.vnet.name
}
resource "azurerm_virtual_network_peering" "fw-panorama-peer" {
  name = "${var.name_prefix}-mgmt-peering-r"
  remote_virtual_network_id = module.vm-series.vnet.id
  resource_group_name = module.panorama.resource-group.name
  virtual_network_name = module.panorama.vnet.name
}

# Permit the traffic between the vmseries VNET and the Panorama VNET
resource "azurerm_network_security_rule" "inter-vnet-rule" {
  name = "${var.name_prefix}-sgrule-intervnet"
  resource_group_name = module.panorama.resource-group.name
  access = "Allow"
  direction = "Inbound"
  network_security_group_name = module.panorama.nsg.name
  priority = 200
  protocol = "*"
  source_port_range = "*"
  source_address_prefix = module.vm-series.subnet-mgmt.address_prefix
  destination_address_prefix = "0.0.0.0/0"
  destination_port_range = "*"
}


# Permit All outbound traffic in Panorma VNET
resource "azurerm_network_security_rule" "panorama-allowall-outbound" {
  name = "${var.name_prefix}-sgrule-allowall"
  resource_group_name = module.panorama.resource-group.name
  access = "Allow"
  direction = "Outbound"
  network_security_group_name = module.panorama.nsg.name
  priority = 100
  protocol = "*"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  destination_port_range = "*"
}

# Permit All outbound traffic in vm-series VNET
resource "azurerm_network_security_rule" "vmseries-allowall-outbound" {
  name = "${var.name_prefix}-sgrule-allowall"
  resource_group_name = module.vm-series.resource-group.name
  access = "Allow"
  direction = "Outbound"
  network_security_group_name = module.vm-series.mgmt-nsg.name
  priority = 100
  protocol = "*"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  destination_port_range = "*"
}