variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "panorama_size" {
  description = "Default size for Panorama"
  default = "Standard_D5_v2"
}

variable "subnet-mgmt" {
  description = "Management subnet."
}

variable "username" {
  description = "Username"
  default = "panadmin"
}

variable "password" {
  description = "Password for Panorama"
}

variable "bootstrap_key_lifetime" {
  description = "Default key lifetime for bootstrap."
  default = "8760"
}