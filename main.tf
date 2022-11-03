resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location

  tags = {
    project     = var.project
    environment = var.environment
    location    = var.location
    tool        = "terraform"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "namespace" {
  for_each = local.namespaces
  name     = "rg-${each.key}-${var.environment}-${var.region}"
  location = var.location
}
