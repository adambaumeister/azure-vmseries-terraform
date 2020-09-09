# Create a route table that directs all outgoing traffic (default route) to the Internal LB
resource "azurerm_route_table" "rt" {
  location = var.location
  name = "${var.remote-vnet.name}-rt"
  resource_group_name = var.remote-vnet.resource_group_name

  route {
    address_prefix = "0.0.0.0/0"
    name = "${var.remote-vnet.name}-rt-default"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = var.lb-ip
  }
}

# asssign the route table to the remote/spoke VNET
resource "azurerm_subnet_route_table_association" "rta" {
  route_table_id = azurerm_route_table.rt.id
  subnet_id = var.remote-subnet.id
}