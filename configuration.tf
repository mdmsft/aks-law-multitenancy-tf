resource "azurerm_app_configuration" "main" {
  name                       = "appcs-${local.resource_suffix}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  local_auth_enabled         = false
  public_network_access      = "Enabled"
  purge_protection_enabled   = var.app_configuration_purge_protection_enabled
  sku                        = "standard"
  soft_delete_retention_days = var.app_configuration_soft_delete_retention_days
}

resource "azurerm_role_assignment" "app_configuration_data_owner" {
  role_definition_name = "App Configuration Data Owner"
  scope                = azurerm_app_configuration.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_role_assignment" "app_configuration_data_reader_global_admin" {
  role_definition_name = "App Configuration Data Reader"
  scope                = azurerm_app_configuration.main.id
  principal_id         = var.global_administrator
}

resource "azurerm_app_configuration_key" "product" {
  for_each               = var.products
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = each.key
  value                  = azurerm_log_analytics_workspace.product[each.key].workspace_id
  label                  = "namespace"

  depends_on = [
    azurerm_role_assignment.app_configuration_data_owner
  ]
}

resource "azurerm_app_configuration_key" "sentinel" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "sentinel"
  value                  = timestamp()
  label                  = "namespace"

  depends_on = [
    azurerm_role_assignment.app_configuration_data_owner
  ]
}

resource "azurerm_app_configuration_feature" "main" {
  configuration_store_id  = azurerm_app_configuration.main.id
  name                    = "BlobifyMessage"
  enabled                 = true
  label                   = "namespace"
  percentage_filter_value = 10

  depends_on = [
    azurerm_role_assignment.app_configuration_data_owner
  ]
}

module "configuration_endpoint" {
  source                         = "./modules/endpoint"
  resource_group_name            = azurerm_resource_group.main.name
  resource_suffix                = "${local.resource_suffix}-appcs"
  subnet_id                      = azurerm_subnet.endpoint.id
  private_connection_resource_id = azurerm_app_configuration.main.id
  subresource_names              = ["configurationStores"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.main["config"].id]

  depends_on = [
    azurerm_app_configuration.main
  ]
}
