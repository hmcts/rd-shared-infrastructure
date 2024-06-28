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

provider "azurerm" {
  alias           = "sds_prod"
  subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
  features {}
}

terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.48.0"
    }
  }
}
