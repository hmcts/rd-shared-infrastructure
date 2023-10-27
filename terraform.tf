provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias                      = "aks-infra"
  skip_provider_registration = true
  subscription_id            = var.aks_infra_subscription_id
  features {}
}

provider "azurerm" {
  alias                      = "mgmt"
  skip_provider_registration = true
  subscription_id            = var.jenkins_subscription_id
  features {}
}

provider "azurerm" {
  alias                      = "rdo"
  skip_provider_registration = true
  subscription_id            = var.hub_prod_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "aks_prod"
  subscription_id = "8cbc6f36-7c56-4963-9d36-739db5d00b27"
  features {}
}

provider "azurerm" {
  alias           = "sendgrid"
  subscription_id = var.env != "prod" ? local.sendgrid_subscription.nonprod : local.sendgrid_subscription.prod
  features {}
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  alias                      = "private_endpoint"
  subscription_id            = var.aks_subscription_id
}

terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.77.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.45.0"
    }
  }
}
