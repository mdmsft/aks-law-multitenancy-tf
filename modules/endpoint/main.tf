data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  name = md5(jsonencode(var.private_dns_zone_ids))
}

resource "azurerm_private_endpoint" "main" {
  name                          = "pe-${var.resource_suffix}"
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "nic-${var.resource_suffix}"

  private_dns_zone_group {
    name                 = local.name
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  private_service_connection {
    name                           = local.name
    is_manual_connection           = false
    subresource_names              = var.subresource_names
    private_connection_resource_id = var.private_connection_resource_id
  }

  lifecycle {
    ignore_changes = [
      location
    ]
  }
}
