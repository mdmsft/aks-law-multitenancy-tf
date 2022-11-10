resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "product" {
  for_each = var.products
  provider = azurerm.product
  name     = "rg-${local.resource_suffix}-${each.key}"
  location = var.location
}
