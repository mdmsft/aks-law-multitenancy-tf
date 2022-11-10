resource "azurerm_service_plan" "main" {
  name                = "plan-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  sku_name            = var.service_plan_sku_name
}

resource "azurerm_windows_function_app" "main" {
  name                          = "func-${local.resource_suffix}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  service_plan_id               = azurerm_service_plan.main.id
  storage_account_name          = azurerm_storage_account.main.name
  storage_uses_managed_identity = true
  builtin_logging_enabled       = true

  site_config {
    always_on                              = true
    use_32_bit_worker                      = false
    vnet_route_all_enabled                 = true
    application_insights_connection_string = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=${azurerm_key_vault_secret.application_insights.name})"

    application_stack {
      dotnet_version              = "6"
      use_dotnet_isolated_runtime = true
    }
  }

  app_settings = {
    "WEBSITE_CONTENTOVERVNET"           = "1",
    "EventHub__fullyQualifiedNamespace" = "${azurerm_eventhub_namespace.main.name}.servicebus.windows.net"
    "EVENT_HUB_NAME"                    = azurerm_eventhub.main.name
    "APP_CONFIGURATION_URI"             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=${azurerm_key_vault_secret.app_configuration.name})"
    "BLOB_CONTAINER_URI"                = "${trimsuffix(azurerm_storage_account.main.primary_blob_endpoint, "/")}/${azurerm_storage_container.messages.name}"
    "VAULT_URI"                         = azurerm_key_vault.main.vault_uri
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags,
      virtual_network_subnet_id
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_windows_function_app.main.id
  subnet_id      = azurerm_subnet.function.id
}

resource "azurerm_app_service_source_control" "main" {
  app_id                 = azurerm_windows_function_app.main.id
  branch                 = "main"
  repo_url               = "https://github.com/mdmsft/ContainerLogExporter"
  use_manual_integration = true
}

resource "azurerm_role_assignment" "function_storage_blob_data_contributor" {
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_storage_account.main.id
}

resource "azurerm_role_assignment" "function_storage_table_data_contributor" {
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_storage_account.main.id
}

resource "azurerm_role_assignment" "function_storage_queue_data_contributor" {
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_storage_account.main.id
}

resource "azurerm_role_assignment" "function_storage_file_data_smb_share_contributor" {
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_storage_account.main.id
}

resource "azurerm_role_assignment" "function_network_contributor" {
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_subnet.function.id
}

resource "azurerm_role_assignment" "function_monitoring_metrics_publisher" {
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_role_assignment" "function_monitoring_metrics_publisher_product" {
  provider             = azurerm.product
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = "/subscriptions/${var.product_subscription_id}"
}

resource "azurerm_role_assignment" "function_azure_event_hubs_data_receiver" {
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_eventhub.main.id
}

resource "azurerm_role_assignment" "function_app_configuration_data_reader" {
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_windows_function_app.main.identity.0.principal_id
  scope                = azurerm_app_configuration.main.id
}

resource "azurerm_monitor_diagnostic_setting" "function" {
  name                       = "Logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  target_resource_id         = azurerm_windows_function_app.main.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.function.log_category_types

    content {
      category = log.value
      enabled  = true
      retention_policy {
        days    = 1
        enabled = true
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}
