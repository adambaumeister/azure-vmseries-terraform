# Setup the variables we need...
variable "location" {
  type = string
  description = "The Azure region to use."
  default = "Australia Central"
}
variable "name_prefix" {
  type = string
  description = "A prefix for all naming conventions - used globally"
  default = "pantf"
}
variable "rules" {
  type = list(object({
    port = number
    name = string
  }))
}

variable "username" {
  default = "panadmin"
  description = "Username to use for all systems"
}

variable "password" {
  description = "Admin password to use for all systems"
}

variable "management_ips" {
  type = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network"
}

variable "olb-private-ip" {
  # This IP MUST be in the same subnet as the firewall "internal" interfaces
  description = "The private IP address to assign to the Outgoing Load balancer frontend"
  default = "172.16.1.250"
}