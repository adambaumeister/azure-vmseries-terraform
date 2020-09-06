variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "rules" {
  type = list(object({
    port = number
    nat_ip = string
  }))
}

variable "backend-nics" {
}
