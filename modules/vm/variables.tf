variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "vmseries_size" {
  description = "Default size for VM series"
  default = "Standard_D5_v2"
}
