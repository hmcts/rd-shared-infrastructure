provider "azurerm" {
  alias           = "mgmt"
  subscription_id = "${var.mgmt_subscription_id}"
  version         = "=1.33.1"
}

locals {
  account_name      = "${replace("${var.product}${var.env}", "-", "")}"
  mgmt_network_name = "${var.subscription == "prod" || var.subscription == "nonprod" ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"

  // for each client service two containers are created: one named after the service
  // and another one, named {service_name}-rejected, for storing envelopes rejected by bulk-scan
  client_service_names = ["jrdtest"]
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "jenkins-subnet"
  virtual_network_name = "${local.mgmt_network_name}"
  resource_group_name  = "${local.mgmt_network_name}"
}

resource "azurerm_storage_account" "storage_account" {
  name                = "${local.account_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location                 = "UK West"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"

 // custom_domain {
 //   name          = "${var.external_hostname}"
  //  use_subdomain = "false"
 // }

  tags = "${local.tags}"
}

resource "azurerm_storage_container" "service_containers" {
  name                 = "${local.client_service_names[count.index]}"
  resource_group_name  = "${azurerm_storage_account.storage_account.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"
  count                = "${length(local.client_service_names)}"
}

resource "azurerm_storage_container" "service_rejected_containers" {
  name                 = "${local.client_service_names[count.index]}-rejected"
  resource_group_name  = "${azurerm_storage_account.storage_account.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"
  count                = "${length(local.client_service_names)}"
}

resource "azurerm_key_vault_secret" "storage_account_name" {
  name      = "storage-account-name"
  value     = "${azurerm_storage_account.storage_account.name}"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  name      = "storage-account-primary-key"
  value     = "${azurerm_storage_account.storage_account.primary_access_key}"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.storage_account.name}"
}

output "storage_account_primary_key" {
  sensitive = true
  value     = "${azurerm_storage_account.storage_account.primary_access_key}"
}
