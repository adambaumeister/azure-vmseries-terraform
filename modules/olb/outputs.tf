output "backend-pool-id" {
  value = azurerm_lb_backend_address_pool.lb-backend.id
}

output "frontend-ip-configs" {
  value = toset([for c in azurerm_lb.lb.frontend_ip_configuration : c.name])
}