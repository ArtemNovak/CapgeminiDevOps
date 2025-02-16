output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_zone1_id" {
  description = "ID of the subnet in zone 1"
  value       = azurerm_subnet.subnet_zone1.id
}

output "subnet_zone2_id" {
  description = "ID of the subnet in zone 2"
  value       = azurerm_subnet.subnet_zone2.id
}

output "lb_backend_pool_id" {
  description = "ID of the load balancer backend pool"
  value       = azurerm_lb_backend_address_pool.backend_pool.id
}

output "lb_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb_ip.ip_address
}

output "lb_nat_pool_id" {
  description = "ID of the load balancer NAT pool"
  value = azurerm_lb_nat_pool.ssh.id
}

