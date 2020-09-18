provider "azurerm" {
  version = "=1.44.0"
}

provider "azurerm" {
  alias           = "aks-infra"
  subscription_id = "${var.aks_infra_subscription_id}"
}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = "${var.jenkins_subscription_id}"
}

provider "azurerm" {
  alias           = "jenkins"
  subscription_id = "${var.jenkins_subscription_id}"
}

provider "azurerm" {
  alias           = "rdo"
  subscription_id = "${var.hub_prod_subscription_id}"
}