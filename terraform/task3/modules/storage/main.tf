resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  blob_properties {
    versioning_enabled = var.enable_versioning
  }
}

resource "azurerm_storage_container" "container" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.storage.id
}