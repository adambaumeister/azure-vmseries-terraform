variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "private-ip" {
  description = "Private IP address to assign to the frontend of the loadbalancer"
}


variable "backend-subnet" {
}
