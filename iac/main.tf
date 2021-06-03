terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.56.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name = "tstate"
    storage_account_name = "tstate29482"
    container_name= "tstate"
    key= "aks.state"
  }
}

resource "random_string" "rgsuffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
    name = "rg-${random_string.rgsuffix.result}"
    location = var.location
}

module "aks" {
  source                             = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location                           = var.location
  location_short  = var.location_short
  environment = "tst"

  kubernetes_version                 = "1.19.11"
}
