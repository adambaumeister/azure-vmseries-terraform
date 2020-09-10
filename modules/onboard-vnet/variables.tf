variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "remote-vnet" {
  description = "Remote or spoke VNET to connect from"
}

variable "remote-subnet" {
  description = "Remote or spoke SUBNET within remote-vnet to apply routing to"
}

variable "lb-ip" {
  description = "Private IP address of LB to use as next hop router for remote-subnet."
}