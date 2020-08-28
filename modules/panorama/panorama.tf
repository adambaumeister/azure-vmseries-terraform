# Base resource group
resource "azurerm_resource_group" "panorama" {
  location = var.location
  name = "${var.name_prefix}-rg-panorama"
}

# Create the out of band network
resource "azurerm_virtual_network" "vnet-mgmt" {
  address_space = ["10.10.10.0/24"]
  location = var.location
  name = "${var.name_prefix}-vnet-mgmt"
  resource_group_name = azurerm_resource_group.panorama.name
}
resource "azurerm_subnet" "subnet-mgmt" {
  name = "${var.name_prefix}-net-mgmt"
  address_prefix = "10.10.10.0/26"
  resource_group_name = azurerm_resource_group.panorama.name
  virtual_network_name = azurerm_virtual_network.vnet-mgmt.name
}

# Build the management interface
resource "azurerm_network_interface" "mgmt" {
  location = azurerm_resource_group.panorama.location
  name = "${var.name_prefix}-nic-mgmt"
  resource_group_name = azurerm_resource_group.panorama.name
  ip_configuration {
    subnet_id = azurerm_subnet.subnet-mgmt.id
    name = "${var.name_prefix}-ip-mgmt"
    private_ip_address_allocation = "static"
    private_ip_address = "10.10.10.10"
  }
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  name                  = "${var.name_prefix}-panorama"
  location              = azurerm_resource_group.panorama.location
  resource_group_name   = azurerm_resource_group.panorama.name
  network_interface_ids = [azurerm_network_interface.mgmt.id]
  vm_size               = var.panorama_size

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "panorama"
    sku       = "byol"
    version   = "9.0.5"
  }
  storage_os_disk {
    name              = "${var.name_prefix}PanoramaDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "panadmin"
    admin_password = "NicePassword!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  plan {
    name = "byol"
    product = "panorama"
    publisher = "paloaltonetworks"
  }
}