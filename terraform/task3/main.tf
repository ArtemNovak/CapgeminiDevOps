resource "azurerm_resource_group" "artemnovakgroup" {
  name     = "${var.prefix}-rg"
  location = "westeurope"
}

module "storage" {
  source = "./modules/storage"

  resource_group_name  = azurerm_resource_group.artemnovakgroup.name
  location             = azurerm_resource_group.artemnovakgroup.location
  storage_account_name = "${var.prefix}storage"
  container_name       = "${var.prefix}container"

}

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.artemnovakgroup.name
  location            = azurerm_resource_group.artemnovakgroup.location
  prefix              = var.prefix
  vnet_name           = "${var.prefix}-vnet"

}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.artemnovakgroup.name
  location            = azurerm_resource_group.artemnovakgroup.location
  prefix              = var.prefix
  subnet_zone1_id     = module.networking.subnet_zone1_id
  subnet_zone2_id     = module.networking.subnet_zone2_id

  depends_on = [module.networking]
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.artemnovakgroup.name
  location            = azurerm_resource_group.artemnovakgroup.location
  prefix              = var.prefix
  subnet_id           = module.networking.subnet_zone1_id
  lb_backend_pool_id  = module.networking.lb_backend_pool_id
  lb_nat_pool_id      = module.networking.lb_nat_pool_id
  

  depends_on = [module.networking, module.security]
}