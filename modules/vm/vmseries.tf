## All the config required for a single VM series Firewall in Azure

# Create a public IP for management
resource "azurerm_public_ip" "pip-fw-mgmt" {
  allocation_method = "Static"
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-fw-pip"
  resource_group_name = azurerm_resource_group.vmseries.name
}

resource "azurerm_virtual_network" "vnet-vmseries" {
  address_space = ["172.16.0.0/16"]
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-vnet-vmseries"
  resource_group_name = azurerm_resource_group.vmseries.name
}


resource "azurerm_subnet" "subnet-mgmt" {
  name = "${var.name_prefix}-net-vmseries-mgmt"
  address_prefix = "172.16.0.0/24"
  resource_group_name = azurerm_resource_group.vmseries.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}

resource "azurerm_network_security_group" "sg-mgmt" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-sg-vmmgmt"
  resource_group_name = azurerm_resource_group.vmseries.name
}

resource "azurerm_subnet_network_security_group_association" "mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-mgmt.id
  subnet_id = azurerm_subnet.subnet-mgmt.id
}

resource "azurerm_network_security_rule" "management-rules" {
  for_each = var.management_ips
  name = "${var.name_prefix}-mgmt-sgrule-${each.key}-22"
  resource_group_name = azurerm_resource_group.vmseries.name
  access = "Allow"
  direction = "Inbound"
  network_security_group_name = azurerm_network_security_group.sg-mgmt.name
  priority = each.value
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = each.key
  destination_address_prefix = "0.0.0.0/0"
  destination_port_range = "*"
}


resource "azurerm_network_interface" "nic-fw-mgmt" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-mgmt"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = azurerm_subnet.subnet-mgmt.id
    name = "${var.name_prefix}-fw-ip-mgmt"
    private_ip_address_allocation = "static"
    private_ip_address = "172.16.0.10"
    public_ip_address_id = azurerm_public_ip.pip-fw-mgmt.id
  }
}

resource "azurerm_subnet" "subnet-inside" {
  name = "${var.name_prefix}-net-inside"
  address_prefix = "172.16.1.0/24"
  resource_group_name = azurerm_resource_group.vmseries.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}
resource "azurerm_network_interface" "nic-fw-inside" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-inside"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = azurerm_subnet.subnet-inside.id
    name = "${var.name_prefix}-fw-ip-inside"
    private_ip_address_allocation = "static"
    private_ip_address = "172.16.1.10"
  }
}

resource "azurerm_subnet" "subnet-outside" {
  name = "${var.name_prefix}-net-outside"
  address_prefix = "172.16.2.0/24"
  resource_group_name = azurerm_resource_group.vmseries.name
  virtual_network_name =  azurerm_virtual_network.vnet-vmseries.name
}
resource "azurerm_network_interface" "nic-fw-outside" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-nic-fw-outside"
  resource_group_name = azurerm_resource_group.vmseries.name
  ip_configuration {
    subnet_id = azurerm_subnet.subnet-outside.id
    name = "${var.name_prefix}-fw-ip-outside"
    private_ip_address_allocation = "static"
    private_ip_address = "172.16.2.10"
  }
}


resource "azurerm_virtual_machine" "fw" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-fw"
  network_interface_ids = [
    azurerm_network_interface.nic-fw-mgmt.id,
    azurerm_network_interface.nic-fw-inside.id,
    azurerm_network_interface.nic-fw-outside.id
  ]
  resource_group_name = azurerm_resource_group.vmseries.name
  vm_size = var.vmseries_size
  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = "bundle2"
    version   = "9.0.4"
  }

  storage_os_disk {
    create_option = "FromImage"
    name = "${var.name_prefix}-vhd-fw"
    caching = "ReadWrite"
    vhd_uri = "${azurerm_storage_account.bootstrap-storage-account.primary_blob_endpoint}vhds/${var.name_prefix}-fw.vhd"
  }


  primary_network_interface_id = azurerm_network_interface.nic-fw-mgmt.id
  os_profile {
    admin_username = "panadmin"
    computer_name = "${var.name_prefix}-fw"
    admin_password = "NicePassword!"
    custom_data = join(
            ",",
            [
              "storage-account=${azurerm_storage_account.bootstrap-storage-account.name}",
              "access-key=${azurerm_storage_account.bootstrap-storage-account.primary_access_key}",
              "file-share=${azurerm_storage_share.bootstrap-storage-share.name}",
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
  depends_on = [
    azurerm_storage_account.bootstrap-storage-account,
    azurerm_storage_share.bootstrap-storage-share,
    null_resource.uploadfile
  ]
}