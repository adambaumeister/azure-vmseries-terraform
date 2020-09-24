variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}
variable "management_ips" {
  type = map(any)
}
variable "management_vnet_prefix" {
  default     = "10.255."
  description = "The private prefix used for the management virtual network"
}

variable "management_subnet" {
  # Joined with management_vnet_prefix on deploy
  # ${management_vnet_prefix}${management_subnet}
  default     = "0.0/24"
  description = "The private network that terminates all FW and Panorama IP addresses."
}

variable "firewall_vnet_prefix" {
  default     = "10.110."
  description = "The private prefix used for all firewall networks"
}

variable "public_subnet" {
  default     = "129.0/24"
  description = "The private network that is the external or public side of the VM series firewalls (eth1/1)"
}

variable "private_subnet" {
  default     = "0.0/24"
  description = "The private network behind or on the internal side of the VM series firewalls (eth1/2)"
}

variable "vm_management_subnet" {
  default     = "255.0/24"
  description = "The subnet used for the management NICs on the vm-series"
}

variable "olb_private_ip" {
  # This IP MUST fall in the private-subnet network.
  description = "The private IP address to assign to the Outgoing Load balancer frontend"
  default     = "10.110.0.21"
}


