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

variable "subnet_zone1_id" {
  description = "ID of the subnet in availability zone 1"
  type        = string
}

variable "subnet_zone2_id" {
  description = "ID of the subnet in availability zone 2"
  type        = string
}