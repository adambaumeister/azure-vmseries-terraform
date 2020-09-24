output "pip-ips" {

  value = {
    for pip in azurerm_public_ip.lb-fip-pip :
    pip.id => pip.ip_address
  }
}
output "pip" {
  value = azurerm_public_ip.lb-fip-pip
}

output "backend-pool-id" {
  value = azurerm_lb_backend_address_pool.lb-backend.id
}
output "frontend-ip-configs" {
  value = toset([for c in azurerm_lb.lb.frontend_ip_configuration : c.name])
}