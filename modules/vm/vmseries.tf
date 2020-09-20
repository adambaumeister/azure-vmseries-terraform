## All the config required for a single VM series Firewall in Azure
# Base resource group
resource "azurerm_resource_group" "vmseries" {
  location = var.location
  name = "${var.name_prefix}-vmseries-rg"
}

# inbound
resource "azurerm_virtual_machine_scale_set" "inbound-scale-set" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-inbound-scaleset"
  resource_group_name = azurerm_resource_group.vmseries.name
  upgrade_policy_mode = "Manual"
  network_profile {
    name = "${var.name_prefix}-inbound-nic-fw-mgmt-profile"
    primary = true
    ip_configuration {
      name = "${var.name_prefix}-inbound-nic-fw-mgmt"
      primary = true
      subnet_id = var.subnet-mgmt.id
      public_ip_address_configuration {
        idle_timeout = 4
        name = "${var.name_prefix}-inbound-fw-mgmt-pip"
        domain_name_label = "${var.name_prefix}-inbound-vm-mgmt"
      }
    }
    ip_forwarding = true

  }
  network_profile {
    name = "${var.name_prefix}-inbound-nic-fw-public-profile"
    primary = false
    ip_configuration {
      name = "${var.name_prefix}-inbound-nic-fw-public"
      primary = false
      subnet_id = var.subnet-private.id
      load_balancer_backend_address_pool_ids = [
        var.public_backend_pool_id]
    }
    ip_forwarding = true

  }

  network_profile {
    name = "${var.name_prefix}-inbound-nic-fw-private-profile"
    primary = false
    ip_configuration {
      name = "${var.name_prefix}-inbound-nic-fw-private"
      primary = false
      subnet_id = var.subnet-private.id
    }
    ip_forwarding = true
  }

  os_profile {
    admin_username = var.username
    computer_name_prefix = "${var.name_prefix}-inbound-fw"
    admin_password = var.password

    custom_data = join(
            ",",
            [
              "storage-account=${var.bootstrap-storage-account.name}",
              "access-key=${var.bootstrap-storage-account.primary_access_key}",
              "file-share=${var.inbound-bootstrap-share-name}",
              "share-directory=None"
            ]
      )
  }
  storage_profile_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = var.vm_series_sku
    version   = var.vm_series_version
  }
  sku {
    capacity = 1
    name = var.vmseries_size
  }
  storage_profile_os_disk {
    create_option = "FromImage"
    name = "${var.name_prefix}-vhd-profile"
    caching = "ReadWrite"
    vhd_containers = ["${var.bootstrap-storage-account.primary_blob_endpoint}${var.vhd-container}"]
  }
  plan {
    name = "bundle2"
    publisher = "paloaltonetworks"
    product = "vmseries1"
  }
}

# Outbound
resource "azurerm_virtual_machine_scale_set" "outbound-scale-set" {
  location = azurerm_resource_group.vmseries.location
  name = "${var.name_prefix}-outbound-scaleset"
  resource_group_name = azurerm_resource_group.vmseries.name
  upgrade_policy_mode = "Manual"
  network_profile {
    name = "${var.name_prefix}-outbound-nic-fw-mgmt-profile"
    primary = true
    ip_configuration {
      name = "${var.name_prefix}-outbound-nic-fw-mgmt"
      primary = true
      subnet_id = var.subnet-mgmt.id
      public_ip_address_configuration {
        idle_timeout = 4
        name = "${var.name_prefix}-outbound-fw-mgmt-pip"
        domain_name_label = "${var.name_prefix}-outbound-vm-mgmt"
      }
    }
    ip_forwarding = true

  }
  network_profile {
    name = "${var.name_prefix}-outbound-nic-fw-public-profile"
    primary = false
    ip_configuration {
      name = "${var.name_prefix}-outbound-nic-fw-public"
      primary = false
      subnet_id = var.subnet-private.id
      public_ip_address_configuration {
        idle_timeout = 4
        name = "${var.name_prefix}-outbound-fw-public-pip"
        domain_name_label = "${var.name_prefix}-outbound-vm-public"
      }
    }
    ip_forwarding = true

  }

  network_profile {
    name = "${var.name_prefix}-outbound-nic-fw-private-profile"
    primary = false
    ip_configuration {
      name = "${var.name_prefix}-outbound-nic-fw-private"
      primary = false
      subnet_id = var.subnet-private.id
      load_balancer_backend_address_pool_ids = [var.private_backend_pool_id]

    }
    ip_forwarding = true
  }

  os_profile {
    admin_username = var.username
    computer_name_prefix = "${var.name_prefix}-outbound-fw"
    admin_password = var.password

    custom_data = join(
            ",",
            [
              "storage-account=${var.bootstrap-storage-account.name}",
              "access-key=${var.bootstrap-storage-account.primary_access_key}",
              "file-share=${var.outbound-bootstrap-share-name}",
              "share-directory=None"
            ]
      )
  }
  storage_profile_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = var.vm_series_sku
    version   = var.vm_series_version
  }
  sku {
    capacity = 1
    name = var.vmseries_size
  }
  plan {
    name = "bundle2"
    publisher = "paloaltonetworks"
    product = "vmseries1"
  }
  storage_profile_os_disk {
    create_option = "FromImage"
    name = "${var.name_prefix}-vhd-profile"
    caching = "ReadWrite"
    vhd_containers = ["${var.bootstrap-storage-account.primary_blob_endpoint}${var.vhd-container}"]
  }
}