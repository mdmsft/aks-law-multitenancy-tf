resource "azurerm_storage_account" "main" {
  name                            = "st${var.project}${var.environment}${var.region}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  access_tier                     = var.storage_account_access_tier
  account_replication_type        = var.storage_account_replication_type
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
}

resource "azurerm_storage_container" "messages" {
  name                 = "messages"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_role_assignment" "storage_blob_data_reader_global_admin" {
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_container.messages.resource_manager_id
  principal_id         = var.global_administrator
}

module "storage_endpoint" {
  for_each                       = toset(["blob", "table", "queue", "file"])
  source                         = "./modules/endpoint"
  resource_group_name            = azurerm_resource_group.main.name
  resource_suffix                = "${local.resource_suffix}-${each.key}"
  subnet_id                      = azurerm_subnet.endpoint.id
  private_connection_resource_id = azurerm_storage_account.main.id
  subresource_names              = [each.key]
  private_dns_zone_ids           = [azurerm_private_dns_zone.main[each.key].id]

  depends_on = [
    azurerm_storage_account.main
  ]
}
