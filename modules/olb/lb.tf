# Sets up an Azure LB and associated rules
# This sets up an OUTBOUND LB and associated rules
# It does not have a public IP associated with it.

resource "azurerm_resource_group" "rg-lb" {
  location = var.location
  name = "${var.name_prefix}-olb-rg"
}

resource "azurerm_lb" "lb" {
  location = var.location
  name = "${var.name_prefix}-olb"
  resource_group_name = azurerm_resource_group.rg-lb.name
  sku = "standard"
  frontend_ip_configuration {
    name = "${var.name_prefix}-olb-fip"
    private_ip_address = var.private-ip
    subnet_id = var.backend-subnet
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name = "${var.name_prefix}-olb-backend"
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-backend-assoc" {
  for_each = { for nic in var.backend-nics : nic.name => nic }
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id
  ip_configuration_name = each.value.ip_configuration[0].name
  network_interface_id = each.value.id

}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name = "${var.name_prefix}-olb-probe-80"
  port = 80
  resource_group_name = azurerm_resource_group.rg-lb.name
}

# This LB rule forwards all traffic on all ports to the provided backend servers.
resource "azurerm_lb_rule" "lb-rules" {
  backend_port = 0
  frontend_ip_configuration_name = "${var.name_prefix}-olb-fip"
  frontend_port = 0
  loadbalancer_id = azurerm_lb.lb.id
  name = "${azurerm_lb.lb.name}-lbrule-all"
  protocol = "All"
  resource_group_name = azurerm_resource_group.rg-lb.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id
  probe_id = azurerm_lb_probe.probe.id

}