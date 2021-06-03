locals {

  name_prefix = var.name_prefix
  aks_name    = "${local.name_prefix}-${var.location_short}-${var.environment}-aks"

  default_agent_profile = {
    name                  = "agentpool"
    count                 = 3
    vm_size               = "Standard_DS2_v2"
    os_type               = "Linux"
    availability_zones    = [1, 2, 3]
    enable_auto_scaling   = false
    min_count             = null
    max_count             = null
    type                  = "VirtualMachineScaleSets"
    node_taints           = null
    max_pods              = 110
    os_disk_size_gb       = 128
    enable_node_public_ip = false
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 60
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 200
  }

  default_node_pool = merge(local.default_agent_profile, var.default_node_pool)

  default_tags = {
    env   = var.environment
  }


  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
  nodes_pools               = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)]

}
