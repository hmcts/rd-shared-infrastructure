provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "aks-infra"
  skip_provider_registration = true
  subscription_id = var.aks_infra_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "mgmt"
  skip_provider_registration = true
  subscription_id = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "rdo"
  skip_provider_registration = true
  subscription_id = var.hub_prod_subscription_id
  features {}
}

terraform {
  backend "azurerm" {}

  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.25"
    }
  }
}