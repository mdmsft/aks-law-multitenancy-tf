resource "azurerm_eventhub_namespace" "main" {
  name                          = "evhns-${local.resource_suffix}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  sku                           = "Standard"
  auto_inflate_enabled          = true
  zone_redundant                = true
  local_authentication_enabled  = false
  public_network_access_enabled = false
  maximum_throughput_units      = 3

  network_rulesets {
    default_action                 = "Deny"
    public_network_access_enabled  = false
    trusted_service_access_enabled = true
  }

  lifecycle {
    ignore_changes = [
      network_rulesets.0.default_action
    ]
  }
}

resource "azurerm_eventhub" "main" {
  name                = "evh-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  namespace_name      = azurerm_eventhub_namespace.main.name
  partition_count     = 1
  message_retention   = 1
}

module "eventhub_endpoint" {
  source                         = "./modules/endpoint"
  resource_group_name            = azurerm_resource_group.main.name
  resource_suffix                = "${local.resource_suffix}-evhns"
  subnet_id                      = azurerm_subnet.endpoint.id
  private_connection_resource_id = azurerm_eventhub_namespace.main.id
  subresource_names              = ["namespace"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.main["eventhub"].id]

  depends_on = [
    azurerm_eventhub_namespace.main
  ]
}
