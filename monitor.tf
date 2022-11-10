resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  daily_quota_gb      = var.log_analytics_workspace_daily_quota_gb
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}

resource "azurerm_application_insights" "main" {
  name                          = "appi-${local.resource_suffix}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  application_type              = "web"
  local_authentication_disabled = true
  workspace_id                  = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_monitor_private_link_scope" "main" {
  name                = "ampls-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_monitor_private_link_scoped_service" "workspace" {
  name                = "amplss-${local.resource_suffix}-log"
  resource_group_name = azurerm_resource_group.main.name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_monitor_private_link_scoped_service" "insights" {
  name                = "amplss-${local.resource_suffix}-appi"
  resource_group_name = azurerm_resource_group.main.name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_application_insights.main.id
}

locals {
  monitor_private_dns_zones = [
    "monitor",
    "oms",
    "ods",
    "agentsvc"
  ]
}

module "monitor_private_link_scope_endpoint" {
  source                         = "./modules/endpoint"
  resource_group_name            = azurerm_resource_group.main.name
  resource_suffix                = "${local.resource_suffix}-ampls"
  subnet_id                      = azurerm_subnet.endpoint.id
  private_connection_resource_id = azurerm_monitor_private_link_scope.main.id
  subresource_names              = ["azuremonitor"]
  private_dns_zone_ids           = [for zone in local.monitor_private_dns_zones : azurerm_private_dns_zone.main[zone].id]

  depends_on = [
    azurerm_monitor_private_link_scope.main,
    azurerm_private_dns_zone.main
  ]
}

resource "azurerm_log_analytics_data_export_rule" "eventhub" {
  name                    = azurerm_eventhub.main.name
  resource_group_name     = azurerm_resource_group.main.name
  workspace_resource_id   = azurerm_log_analytics_workspace.main.id
  destination_resource_id = azurerm_eventhub.main.id
  table_names             = ["ContainerLogV2"]
  enabled                 = true
}

resource "azurerm_log_analytics_workspace" "product" {
  for_each            = var.products
  provider            = azurerm.product
  name                = "log-${local.resource_suffix}-${each.key}"
  location            = azurerm_resource_group.product[each.key].location
  resource_group_name = azurerm_resource_group.product[each.key].name
  daily_quota_gb      = var.log_analytics_workspace_daily_quota_gb_per_product
  retention_in_days   = var.log_analytics_workspace_retention_in_days_per_product
}

resource "azurerm_monitor_private_link_scoped_service" "product" {
  for_each            = var.products
  name                = "amplss-${local.resource_suffix}-log-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_log_analytics_workspace.product[each.key].id

  depends_on = [
    azurerm_role_assignment.monitoring_contributor
  ]
}

resource "azurerm_role_assignment" "monitoring_contributor" {
  for_each             = var.products
  provider             = azurerm.product
  role_definition_name = "Monitoring Contributor"
  principal_id         = data.azurerm_client_config.main.object_id
  scope                = azurerm_log_analytics_workspace.product[each.key].id
}
