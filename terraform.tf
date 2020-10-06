provider "azurerm" {
  version = "=2.20.0"
  features {}
}

provider "azurerm" {
  alias           = "aks-infra"
  subscription_id = var.aks_infra_subscription_id
 features {}
}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "jenkins"
  subscription_id = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "rdo"
  subscription_id = var.hub_prod_subscription_id
  features {}
}

terraform {
  backend "azurerm" {}
}