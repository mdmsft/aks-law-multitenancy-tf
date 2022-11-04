locals {
  private_dns_zones = {
    registry = "privatelink.azurecr.io"
    eventhub = "privatelink.servicebus.windows.net"
    monitor  = "privatelink.monitor.azure.com"
    oms      = "privatelink.oms.opinsights.azure.com"
    ods      = "privatelink.ods.opinsights.azure.com"
    agentsvc = "privatelink.agentsvc.azure-automation.net"
    blob     = "privatelink.blob.core.windows.net"
    table    = "privatelink.table.core.windows.net"
    vault    = "privatelink.vaultcore.windows.net"
    config   = "privatelink.azconfig.io"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "cluster" {
  name                 = "snet-aks"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.address_space.0]
}

resource "azurerm_network_security_group" "cluster" {
  name                = "nsg-${local.resource_suffix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "cluster" {
  network_security_group_id = azurerm_network_security_group.cluster.id
  subnet_id                 = azurerm_subnet.cluster.id
}

resource "azurerm_subnet" "endpoint" {
  name                                      = "snet-pe"
  virtual_network_name                      = azurerm_virtual_network.main.name
  resource_group_name                       = azurerm_resource_group.main.name
  address_prefixes                          = [cidrsubnet(var.address_space.1, 1, 0)]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_network_security_group" "endpoint" {
  name                = "nsg-${local.resource_suffix}-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "endpoint" {
  network_security_group_id = azurerm_network_security_group.endpoint.id
  subnet_id                 = azurerm_subnet.endpoint.id
}

resource "azurerm_subnet" "function" {
  name                                          = "snet-func"
  virtual_network_name                          = azurerm_virtual_network.main.name
  resource_group_name                           = azurerm_resource_group.main.name
  address_prefixes                              = [cidrsubnet(var.address_space.1, 1, 1)]
  private_link_service_network_policies_enabled = false

  delegation {
    name = "web"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "function" {
  name                = "nsg-${local.resource_suffix}-func"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "function" {
  network_security_group_id = azurerm_network_security_group.function.id
  subnet_id                 = azurerm_subnet.function.id
}

resource "azurerm_public_ip_prefix" "cluster" {
  name                = "ippre-${local.resource_suffix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  prefix_length       = var.nat_gateway_public_ip_prefix_length
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_nat_gateway" "cluster" {
  name                    = "ng-${local.resource_suffix}-aks"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  idle_timeout_in_minutes = 4
  sku_name                = "Standard"
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "cluster" {
  nat_gateway_id      = azurerm_nat_gateway.cluster.id
  public_ip_prefix_id = azurerm_public_ip_prefix.cluster.id
}

resource "azurerm_subnet_nat_gateway_association" "cluster" {
  nat_gateway_id = azurerm_nat_gateway.cluster.id
  subnet_id      = azurerm_subnet.cluster.id
}

resource "azurerm_private_dns_zone" "main" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each              = local.private_dns_zones
  name                  = azurerm_resource_group.main.name
  private_dns_zone_name = each.value
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.main.id

  depends_on = [
    azurerm_private_dns_zone.main
  ]
}
