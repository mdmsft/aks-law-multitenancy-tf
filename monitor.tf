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
    "agentsvc",
    "blob"
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
    azurerm_monitor_private_link_scope.main
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

resource "azurerm_log_analytics_workspace" "namespace" {
  for_each            = local.namespaces
  name                = "log-${each.key}-${local.common_suffix}"
  location            = azurerm_resource_group.namespace[each.key].location
  resource_group_name = azurerm_resource_group.namespace[each.key].name
  daily_quota_gb      = var.log_analytics_workspace_daily_quota_gb
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}