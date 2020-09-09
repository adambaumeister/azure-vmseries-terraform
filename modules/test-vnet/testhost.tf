# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  location = var.location
  name = "${var.name_prefix}-vmseries-rg"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "${var.name_prefix}-testhost-vnet"
  address_space = [
    "10.100.100.0/24"]
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name = "${var.name_prefix}-testhost-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  network_security_group_id = azurerm_network_security_group.nsg.id
  address_prefix = "10.100.100.0/26"
}

# Create public IPs
resource "azurerm_public_ip" "pip" {
  name = "${var.name_prefix}-testhost-pip"
  sku = "standard"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name = "${var.name_prefix}-testhost-nsg"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "WEB"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name = "${var.name_prefix}-testhost-nic"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "${var.name_prefix}-testhost-ipconfig"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.100.100.10"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_subnet_network_security_group_association" "sgassoc" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id = azurerm_subnet.subnet.id
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name = "${var.name_prefix}hostsa"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" {
  value = "${tls_private_key.example_ssh.private_key_pem}"
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name = "${var.name_prefix}-testhost-vm"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.nic.id]
  vm_size = "Standard_DS1_v2"

  storage_os_disk {
    name = "${var.name_prefix}-testhost-osdisk"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  os_profile_linux_config {

    disable_password_authentication = false
  }
  os_profile {
    computer_name = "${var.name_prefix}-testhost"
    admin_username = "azureuser"
    admin_password = var.admin-password
  }
}

# Setup vnet peering
resource "azurerm_virtual_network_peering" "testhost-fw-peer" {
  name = "${var.name_prefix}-testhost-fw-peering"
  remote_virtual_network_id = var.peer-vnet.id
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  allow_virtual_network_access = true
}
resource "azurerm_virtual_network_peering" "fw-testhost-peer" {
  name = "${var.name_prefix}-fw-testhost-peering"
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  resource_group_name = var.peer-vnet.resource_group_name
  virtual_network_name = var.peer-vnet.name
  allow_virtual_network_access = true
}