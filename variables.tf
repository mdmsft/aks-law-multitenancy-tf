variable "project" {
  type    = string
  default = "contoso"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "region" {
  type    = string
  default = "weu"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "product_tenant_id" {
  type = string
}

variable "product_subscription_id" {
  type = string
}

variable "product_client_id" {
  type = string
}

variable "product_client_secret" {
  type      = string
  sensitive = true
}

variable "address_space" {
  type = list(string)
  default = [
    "192.168.255.0/24",
    "10.255.255.0/24",
  ]
}

variable "kubernetes_cluster_orchestrator_version" {
  type     = string
  nullable = true
  default  = null
}

variable "kubernetes_cluster_sku_tier" {
  type    = string
  default = "Paid"
}

variable "kubernetes_cluster_automatic_channel_upgrade" {
  type    = string
  default = "stable"
}

variable "kubernetes_cluster_azure_policy_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_service_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "kubernetes_cluster_docker_bridge_cidr" {
  type    = string
  default = "10.255.255.0/24"
}

variable "kubernetes_cluster_default_node_pool_vm_size" {
  type    = string
  default = "Standard_D2d_v5"
}

variable "kubernetes_cluster_default_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_default_node_pool_min_count" {
  type    = number
  default = 1
}

variable "kubernetes_cluster_default_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_default_node_pool_os_disk_size_gb" {
  type    = number
  default = 64
}

variable "kubernetes_cluster_default_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "kubernetes_cluster_default_node_pool_max_surge" {
  type    = string
  default = "33%"
}

variable "kubernetes_cluster_default_node_pool_availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "kubernetes_cluster_default_node_pool_orchestrator_version" {
  type     = string
  default  = null
  nullable = true
}

variable "kubernetes_cluster_workload_node_pool_vm_size" {
  type    = string
  default = "Standard_D2d_v5"
}

variable "kubernetes_cluster_workload_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_workload_node_pool_min_count" {
  type    = number
  default = 0
}

variable "kubernetes_cluster_workload_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_workload_node_pool_os_disk_size_gb" {
  type    = number
  default = 64
}

variable "kubernetes_cluster_workload_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "kubernetes_cluster_workload_node_pool_max_surge" {
  type    = string
  default = "33%"
}

variable "kubernetes_cluster_workload_node_pool_availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "kubernetes_cluster_workload_node_pool_orchestrator_version" {
  type     = string
  default  = null
  nullable = true
}

variable "kubernetes_cluster_workload_node_pool_labels" {
  type    = map(string)
  default = {}
}

variable "kubernetes_cluster_workload_node_pool_taints" {
  type    = list(string)
  default = []
}

variable "kubernetes_cluster_network_plugin" {
  type    = string
  default = "azure"
}

variable "kubernetes_cluster_network_policy" {
  type    = string
  default = "azure"
}

variable "kubernetes_cluster_open_service_mesh_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_microsoft_defender_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_key_vault_secrets_provider_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_oidc_issuer_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_workload_identity_enabled" {
  type    = bool
  default = true
}

variable "kubernetes_service_cluster_administrators" {
  type    = list(string)
  default = []
}

variable "kubernetes_service_cluster_users" {
  type    = list(string)
  default = []
}

variable "kubernetes_service_rbac_administrators" {
  type    = list(string)
  default = []
}

variable "kubernetes_service_rbac_cluster_administrators" {
  type    = list(string)
  default = []
}

variable "kubernetes_service_rbac_readers" {
  type    = list(string)
  default = []
}

variable "kubernetes_service_rbac_writers" {
  type    = list(string)
  default = []
}

variable "log_analytics_workspace_daily_quota_gb" {
  type    = number
  default = 30
}

variable "log_analytics_workspace_retention_in_days" {
  type    = number
  default = 30
}

variable "log_analytics_workspace_daily_quota_gb_per_product" {
  type    = number
  default = 1
}

variable "log_analytics_workspace_retention_in_days_per_product" {
  type    = number
  default = 30
}

variable "nat_gateway_public_ip_prefix_length" {
  type    = number
  default = 28
}

variable "key_vault_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "app_configuration_purge_protection_enabled" {
  type    = bool
  default = false
}

variable "app_configuration_soft_delete_retention_days" {
  type    = number
  default = 1
}

variable "eventhub_auto_inflate_enabled" {
  type    = bool
  default = true
}

variable "eventhub_zone_redundant" {
  type    = bool
  default = true
}

variable "eventhub_maximum_throughput_units" {
  type    = number
  default = 3
}

variable "eventhub_partition_count" {
  type    = number
  default = 1
}

variable "eventhub_message_retention" {
  type    = number
  default = 1
}

variable "service_plan_sku_name" {
  type    = string
  default = "B1"
}

variable "storage_account_replication_type" {
  type    = string
  default = "ZRS"
}

variable "storage_account_access_tier" {
  type    = string
  default = "Cool"
}

variable "products" {
  type = map(string)
  default = {
    "red"    = "red"
    "orange" = "orange"
    "yellow" = "yellow"
    "green"  = "green"
    "blue"   = "blue"
    "indigo" = "indigo"
    "violet" = "violet"
  }
}

variable "global_administrator" {
  type = string
}
