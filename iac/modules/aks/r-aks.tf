resource "azurerm_kubernetes_cluster" "aks" {

  name                            = coalesce(var.custom_aks_name, local.aks_name)
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = "${replace(coalesce(var.custom_aks_name, local.aks_name), "/[\\W_]/", "-")}-dns"
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  node_resource_group             = var.node_resource_group
  enable_pod_security_policy      = var.enable_pod_security_policy

  default_node_pool {
    name                = local.default_node_pool.name
    node_count          = local.default_node_pool.count
    vm_size             = local.default_node_pool.vm_size
    availability_zones  = local.default_node_pool.availability_zones
    enable_auto_scaling = local.default_node_pool.enable_auto_scaling
    min_count           = local.default_node_pool.min_count
    max_count           = local.default_node_pool.max_count
    max_pods            = local.default_node_pool.max_pods
    os_disk_size_gb     = local.default_node_pool.os_disk_size_gb
    type                = local.default_node_pool.type
    vnet_subnet_id      = lookup(local.default_node_pool, "vnet_subnet_id", null)
    node_taints         = local.default_node_pool.node_taints
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = var.addons.oms_agent_workspace_id
    }

    azure_policy {
      enabled = var.addons.policy
    }

    http_application_routing {
      enabled =var.addons.http_application_routing
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }

  dynamic "network_profile" {
    for_each = var.use_azurecni == true ? [true] : []
    content {
      network_plugin     = "azure"
      network_policy     = "azure"
      dns_service_ip     = cidrhost(var.service_cidr, 10)
      docker_bridge_cidr = var.docker_bridge_cidr
      service_cidr       = var.service_cidr
      load_balancer_sku  = "standard"
      outbound_type      = var.outbound_type
    }
  }

  role_based_access_control {
    enabled = true
  }

  tags = merge(local.default_tags, var.extra_tags)

  lifecycle {
    ignore_changes = [
      kube_config
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count                 = length(local.nodes_pools)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = local.nodes_pools[count.index].name
  vm_size               = local.nodes_pools[count.index].vm_size
  os_type               = local.nodes_pools[count.index].os_type
  os_disk_size_gb       = local.nodes_pools[count.index].os_disk_size_gb
  vnet_subnet_id        = local.nodes_pools[count.index].vnet_subnet_id
  enable_auto_scaling   = local.nodes_pools[count.index].enable_auto_scaling
  node_count            = local.nodes_pools[count.index].count
  min_count             = local.nodes_pools[count.index].min_count
  max_count             = local.nodes_pools[count.index].max_count
  enable_node_public_ip = local.nodes_pools[count.index].enable_node_public_ip
  availability_zones    = local.nodes_pools[count.index].availability_zones
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
  role_definition_name = "Contributor"
}
