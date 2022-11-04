resource "azurerm_app_configuration" "main" {
  name                       = "appcs-${local.resource_suffix}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  local_auth_enabled         = false
  public_network_access      = "Enabled"
  purge_protection_enabled   = false
  sku                        = "standard"
  soft_delete_retention_days = 1
}

resource "azurerm_role_assignment" "app_configuration_data_owner" {
  role_definition_name = "App Configuration Data Owner"
  scope                = azurerm_app_configuration.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_app_configuration_key" "namespace" {
  for_each               = local.namespaces
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = each.key
  value                  = azurerm_log_analytics_workspace.namespace[each.key].workspace_id
  label                  = "namespace"

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
