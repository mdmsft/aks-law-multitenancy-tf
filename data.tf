data "azurerm_client_config" "main" {}

data "azuread_client_config" "main" {}

data "azurerm_kubernetes_service_versions" "main" {
  location        = var.location
  include_preview = false
}

data "azurerm_monitor_diagnostic_categories" "function" {
  resource_id = azurerm_windows_function_app.main.id
}
