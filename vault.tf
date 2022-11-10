resource "azurerm_key_vault" "main" {
  name                       = substr("kv-${var.project}-${var.environment}-${var.region}", 0, 24)
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  enable_rbac_authorization  = true
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
}

resource "azurerm_key_vault_secret" "application_insights" {
  name         = "application-insights"
  key_vault_id = azurerm_key_vault.main.id
  value        = azurerm_application_insights.main.connection_string

  depends_on = [
    azurerm_role_assignment.key_vault_administrator
  ]
}

resource "azurerm_key_vault_secret" "app_configuration" {
  name         = "app-configuration"
  key_vault_id = azurerm_key_vault.main.id
  value        = azurerm_app_configuration.main.endpoint

  depends_on = [
    azurerm_role_assignment.key_vault_administrator
  ]
}

resource "azurerm_key_vault_secret" "product" {
  for_each     = var.products
  name         = each.key
  value        = azurerm_log_analytics_workspace.product[each.key].primary_shared_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.key_vault_administrator
  ]
}

resource "azurerm_role_assignment" "key_vault_administrator" {
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.main.id
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
}

resource "azurerm_role_assignment" "key_vault_secrets_user_global_admin" {
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.main.id
  principal_id         = var.global_administrator
}

module "vault_endpoint" {
  source                         = "./modules/endpoint"
  resource_group_name            = azurerm_resource_group.main.name
  resource_suffix                = "${local.resource_suffix}-kv"
  subnet_id                      = azurerm_subnet.endpoint.id
  private_connection_resource_id = azurerm_key_vault.main.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.main["vault"].id]

  depends_on = [
    azurerm_key_vault.main
  ]
}
