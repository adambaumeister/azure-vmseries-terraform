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