provider "azurerm" {
  version = "=2.30.0"
  features {}
}

provider "azurerm" {
  alias           = "aks-infra"
  version         = "=2.30.0"
  subscription_id = var.aks_infra_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "mgmt"
  version         = "=2.30.0"
  subscription_id = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "jenkins"
  version         = "=2.30.0"
  subscription_id = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "rdo"
  version         = "=2.30.0"
  subscription_id = var.hub_prod_subscription_id
  features {}
}

terraform {
  backend "azurerm" {}
}