output "nsg_zone1_id" {
  description = "ID of the network security group for zone 1"
  value       = azurerm_network_security_group.vm_nsg_zone1.id
}

output "nsg_zone2_id" {
  description = "ID of the network security group for zone 2"
  value       = azurerm_network_security_group.vm_nsg_zone2.id
}