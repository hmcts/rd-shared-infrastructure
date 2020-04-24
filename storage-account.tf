provider "azurerm" {
  alias           = "aks-infra"
  subscription_id = "${var.aks_infra_subscription_id}"
}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = "${var.mgmt_subscription_id}"
}

locals {
  account_name      = "${replace("${var.product}${var.env}", "-", "")}"
  mgmt_network_name = "core-infra-vnet-demo"
  mgmt_network_rg_name = "core-infra-demo"



  // for each client service two containers are created: one named after the service
  // and another one, named {service_name}-rejected, for storing envelopes rejected by bulk-scan
  client_service_names = ["jud-ref-data"]
}



module "storage_account" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=master"
  env                      = "${var.env}"
  storage_account_name     = "${local.account_name}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.location}"
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  //  enable_blob_encryption    = true
  //  enable_file_encryption    = true
  enable_https_traffic_only = true

  // Tags
  common_tags  = "${local.tags}"
  team_contact = "${var.team_contact}"
  destroy_me   = "${var.destroy_me}"

}

data "azurerm_virtual_network" "mgmt_vnet" {
  provider            = "azurerm.mgmt"
  name                = "${local.mgmt_network_name}"
  resource_group_name = "${local.mgmt_network_name}"
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "iaas"
  virtual_network_name = "core-cftptl-intsvc-vnet"
  resource_group_name  = "aks-infra-cftptl-intsvc-rg"
}

resource "azurerm_storage_container" "service_containers" {
  name                 = "${local.client_service_names[count.index]}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${module.storage_account.storageaccount_name}"
  count                = "${length(local.client_service_names)}"
}

resource "azurerm_storage_container" "service_rejected_containers" {
  name                 = "${local.client_service_names[count.index]}-archive"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${module.storage_account.storageaccount_name}"
  count                = "${length(local.client_service_names)}"
}

resource "azurerm_key_vault_secret" "storage_account_name" {
  name      = "storage-account-name"
  value     = "${module.storage_account.storageaccount_name}"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

resource "azurerm_key_vault_secret" "storageaccount_id" {
  name         = "storage-account-id"
  value        = "${module.storage_account.storageaccount_id}"
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  name      = "storage-account-primary-key"
  value     = "${module.storage_account.storageaccount_primary_access_key}"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

output "storage_account_name" {
  value = "${module.storage_account.storageaccount_name}"
}

output "storage_account_primary_key" {
  sensitive = true
  value     = "${module.storage_account.storageaccount_primary_access_key}"
}

