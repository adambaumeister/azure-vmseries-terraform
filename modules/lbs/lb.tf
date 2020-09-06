# Sets up an Azure LB and associated rules

resource "azurerm_resource_group" "rg-lb" {
  location = var.location
  name = "${var.name_prefix}-lb-rg"
}

resource "azurerm_public_ip" "lb-fip-pip" {
  for_each = { for rule in var.rules : rule.port => rule }
  allocation_method = "Static"
  location = azurerm_resource_group.rg-lb.location
  name = "${var.name_prefix}-${each.value.port}"
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_lb" "lb" {
  location = var.location
  name = "${var.name_prefix}-lb"
  resource_group_name = azurerm_resource_group.rg-lb.name
  dynamic "frontend_ip_configuration" {
    for_each = azurerm_public_ip.lb-fip-pip
    content {
      name = "${var.name_prefix}-lb-fip"
      public_ip_address_id = frontend_ip_configuration.value.id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name = "${var.name_prefix}-lb-backend"
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-backend-assoc" {
  for_each = { for nic in var.backend-nics : nic.id => nic }
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id
  ip_configuration_name = each.value.ip_configuration[0].name
  network_interface_id = each.value.id
}

resource "azurerm_lb_rule" "lb-rules" {
  for_each = { for rule in var.rules : rule.port => rule }
  backend_port = each.value.port
  frontend_ip_configuration_name = "${var.name_prefix}-lb-fip"
  frontend_port = each.value.port
  loadbalancer_id = azurerm_lb.lb.id
  name = "${each.value.nat_ip}-lbrule"
  protocol = "Tcp"
  resource_group_name = azurerm_resource_group.rg-lb.name
  enable_floating_ip = true
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id
}