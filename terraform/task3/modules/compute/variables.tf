variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where VMs will be placed"
  type        = string
}

variable "lb_backend_pool_id" {
  description = "ID of the load balancer backend pool"
  type        = string
}

variable "lb_nat_pool_id" {
  description = "ID of the load balancer NAT pool"
  type        = string
}