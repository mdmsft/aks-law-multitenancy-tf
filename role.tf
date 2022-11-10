resource "azurerm_role_definition" "log_analytics_data_publisher" {
  provider = azurerm.product
  name     = "Log Analytics Data Publisher"
  scope    = "/subscriptions/${var.product_subscription_id}"
  assignable_scopes = [
    "/subscriptions/${var.product_subscription_id}"
  ]
  permissions {
    actions = [
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/sharedKeys/action"
    ]
    data_actions = [
      "Microsoft.Insights/Metrics/Write",
      "Microsoft.Insights/Telemetry/Write"
    ]
  }
}
