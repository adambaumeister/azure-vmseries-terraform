## All the config required for a single VM series Firewall in Azure
# Base resource group
resource "azurerm_resource_group" "vmseries" {
  location = var.location
  name = "${var.name_prefix}-vmseries-rg"
}
# Create a public IP for management
resource "azurerm_public_ip" "pip-fw-mgmt" {
  allocation_method = "Static"
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-fw-pip"
  sku = "standard"
  resource_group_name = azurerm_resource_group.vmseries.name
}
# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "pip-fw-public" {
  allocation_method = "Static"
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-outside-fw-pip"
  sku = "standard"
  resource_group_name = azurerm_resource_group.vmseries.name
}

resource "azurerm_network_interface" "nic-fw-mgmt" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-mgmt"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = var.subnet-mgmt.id
    name = "${var.name_prefix}-fw-ip-mgmt"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.pip-fw-mgmt.id
  }
}

resource "azurerm_network_interface" "nic-fw-private" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-private"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = var.subnet-private.id
    name = "${var.name_prefix}-fw-ip-inside"
    private_ip_address_allocation = "dynamic"
    //private_ip_address = "172.16.1.10"
  }
  enable_ip_forwarding = true
}

resource "azurerm_network_interface" "nic-fw-public" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-public"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = var.subnet-public.id
    name = "${var.name_prefix}-fw-ip-outside"
    private_ip_address_allocation = "dynamic"
    //private_ip_address = "172.16.2.10"
    public_ip_address_id = azurerm_public_ip.pip-fw-public.id

  }
  enable_ip_forwarding = true

}


resource "azurerm_virtual_machine" "fw" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-fw"
  network_interface_ids = [
    azurerm_network_interface.nic-fw-mgmt.id,
    azurerm_network_interface.nic-fw-private.id,
    azurerm_network_interface.nic-fw-public.id
  ]
  resource_group_name = azurerm_resource_group.vmseries.name
  vm_size = var.vmseries_size
  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = var.vm_series_sku
    version   = var.vm_series_version
  }

  storage_os_disk {
    create_option = "FromImage"
    name = "${var.name_prefix}-vhd-fw"
    caching = "ReadWrite"
    vhd_uri = "${var.bootstrap-storage-account.primary_blob_endpoint}vhds/${var.name_prefix}-fw.vhd"
  }


  primary_network_interface_id = azurerm_network_interface.nic-fw-mgmt.id
  os_profile {
    admin_username = var.username
    computer_name = "${var.name_prefix}-fw"
    admin_password = var.password
    custom_data = join(
            ",",
            [
              "storage-account=${var.bootstrap-storage-account.name}",
              "access-key=${var.bootstrap-storage-account.primary_access_key}",
              "file-share=${var.bootstrap-share-name}",
              "share-directory=None"
            ]
      )
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  plan {
    name = "bundle2"
    publisher = "paloaltonetworks"
    product = "vmseries1"
  }
}
