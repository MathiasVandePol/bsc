variable "location" {
  description = "Azure region to use"
  type        = string
}

variable "location_short" {
  description = "Short name of Azure regions to use"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "custom_aks_name" {
  description = "Custom AKS name"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix used in naming"
  type        = string
  default     = "aks"
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the AKS resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = "1.19.11"
}

variable "api_server_authorized_ip_ranges" {
  description = "Ip ranges allowed to interract with Kubernetes API. Default no restrictions"
  type        = list(string)
  default     = []
}

variable "node_resource_group" {
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
  type        = string
  default     = null
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies"
  type        = bool
  default     = false
}

variable "default_node_pool" {
  description = <<EOD
Default node pool configuration:

```
map(object({
    name                  = string
    count                 = number
    vm_size               = string
    os_type               = string
    availability_zones    = list(number)
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    type                  = string
    node_taints           = list(string)
    vnet_subnet_id        = string
    max_pods              = number
    os_disk_size_gb       = number
    enable_node_public_ip = bool
}))
```

EOD

  type    = map(any)
  default = {}
}

variable "use_azurecni" {
  description = "use azure cni"
  type = bool
  default = false
}

variable "nodes_subnet_id" {
  description = "Id of the subnet used for nodes"
  type        = string
  default = null
}

variable "vnet_id" {
  description = "Id of the vnet used for AKS"
  type        = string
  default = null
}

variable "addons" {
  description = "Kubernetes addons to enable /disable"
  type = object({
    oms_agent              = bool,
    oms_agent_workspace_id = string,
    policy                 = bool
    http_application_routing = bool
  })
  default = {
    oms_agent              = false
    oms_agent_workspace_id = null,
    policy                 = false
    http_application_routing = false
  }
}

variable "linux_profile" {
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
  type = object({
    username = string,
    ssh_key  = string
  })
  default = null
}

variable "service_cidr" {
  description = "CIDR used by kubernetes services (kubectl get svc)."
  type        = string
  default = null
}

variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
  type        = string
  default     = "loadBalancer"
}

variable "docker_bridge_cidr" {
  description = "IP address for docker with Network CIDR."
  type        = string
  default     = "172.16.0.1/16"
}

variable "nodes_pools" {
  description = "A list of nodes pools to create, each item supports same properties as `local.default_agent_profile`"
  type        = list(any)
  default = []

}

variable "container_registries" {
  description = "List of Azure Container Registries ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "storage_contributor" {
  description = "List of storage accounts ids where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "managed_identities" {
  description = "List of managed identities where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "diagnostic_settings_custom_name" {
  description = "Custom name for Azure Diagnostics for AKS."
  type        = string
  default     = "default"
}

variable "diagnostic_settings_logs_destination_ids" {
  description = "List of destination resources IDs for logs diagnostic destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set."
  type        = list(string)
  default     = []
}

variable "diagnostic_settings_event_hub_name" {
  description = "Event hub name used with diagnostics settings"
  type        = string
  default     = null
}

variable "diagnostic_settings_retention_days" {
  description = "The number of days to keep diagnostic logs."
  type        = number
  default     = 30
}

variable "diagnostic_settings_log_categories" {
  description = "List of log categories"
  type        = list(string)
  default     = null
}

variable "diagnostic_settings_metric_categories" {
  description = "List of metric categories"
  type        = list(string)
  default     = null
}

variable "diagnostic_settings_log_analytics_destination_type" {
  description = "When set to 'Dedicated' logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. This only includes Azure Data Factory"
  type        = string
  default     = "AzureDiagnostics"
}