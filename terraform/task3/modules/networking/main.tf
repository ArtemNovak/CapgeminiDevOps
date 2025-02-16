resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

}

resource "azurerm_subnet" "subnet_zone1" {
  name                 = "${var.prefix}-subnet-zone1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_zone1_prefix]
}

resource "azurerm_subnet" "subnet_zone2" {
  name                 = "${var.prefix}-subnet-zone2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_zone2_prefix]
}

resource "azurerm_lb" "app_lb" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

resource "azurerm_public_ip" "lb_ip" {
  name                = "${var.prefix}-lb-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "${var.prefix}-backend-pool"
  loadbalancer_id = azurerm_lb.app_lb.id
}

resource "azurerm_lb_probe" "http_probe" {
  name                = "${var.prefix}-http-probe"
  loadbalancer_id     = azurerm_lb.app_lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/index.html"
  interval_in_seconds = 15
  probe_threshold     = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${var.prefix}-http-rule"
  loadbalancer_id                = azurerm_lb.app_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.app_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

resource "azurerm_lb_nat_pool" "ssh" {
  name                           = "${var.prefix}-ssh-nat-pool"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.app_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.prefix}-frontend-ip"
}