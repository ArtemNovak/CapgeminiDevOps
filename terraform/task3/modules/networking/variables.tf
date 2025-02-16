variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be located"
  type        = string
}

variable "prefix" {
  description = "Prefix to be used for all resources to ensure unique names"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_zone1_prefix" {
  description = "Address prefix for zone 1 subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_zone2_prefix" {
  description = "Address prefix for zone 2 subnet"
  type        = string
  default     = "10.0.2.0/24"
}