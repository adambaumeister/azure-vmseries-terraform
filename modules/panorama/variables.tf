variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "panorama_size" {
  description = "Default size for Panorama"
  default     = "Standard_D5_v2"
}

variable "subnet_mgmt" {
  description = "Management subnet."
}

variable "username" {
  description = "Username"
  default     = "panadmin"
}

variable "password" {
  description = "Password for Panorama"
}

variable "bootstrap_key_lifetime" {
  description = "Default key lifetime for bootstrap."
  default     = "8760"
}

variable "panorama_sku" {
  default = "byol"
}
variable "panorama_version" {
  default = "9.0.5"
}


#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "rg-panorama"
}

variable "name_bootstrap_share" {
  default = "bootstrap"
}

variable "name_inbound_bootstrap_storage_share" {
  default = "ibbootstrapshare"
}

variable "name_outbound-bootstrap-storage-share" {
  default = "obbootstrapshare"
}
variable "name_vm_sc" {
  default = "vm-container"
}

variable "name_panorama_pip_mgmt" {
  default = "panorama-pip"
}

variable "name_mgmt" {
  default = "nic-mgmt"
}

variable "name_panorama" {
  default = "panorama"
}