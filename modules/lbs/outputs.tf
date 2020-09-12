output "pip-ips" {

  value = {
    for pip in azurerm_public_ip.lb-fip-pip:
    pip.id => pip.ip_address
  }
}
output "pip" {
  value = azurerm_public_ip.lb-fip-pip
}
