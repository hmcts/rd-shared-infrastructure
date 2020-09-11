locals {
  account_name          = "${replace("${var.product}${var.env}", "-", "")}"
  mgmt_network_name     = "core-cftptl-intsvc-vnet"
  mgmt_network_rg_name  = "aks-infra-cftptl-intsvc-rg"

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

  sa_subnets = ["${data.azurerm_subnet.aks-00.id}", "${data.azurerm_subnet.aks-01.id}", "${data.azurerm_subnet.jenkins_subnet.id}"]
}

data "azurerm_virtual_network" "mgmt_vnet" {
  provider            = "azurerm.mgmt"
  name                = "${local.mgmt_network_name}"
  resource_group_name = "${local.mgmt_network_rg_name}"
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "iaas"
  virtual_network_name = "${data.azurerm_virtual_network.mgmt_vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.mgmt_vnet.resource_group_name}"
}

data "azurerm_virtual_network" "aks_core_vnet" {
  provider            = "azurerm.aks-infra"
  name                = "core-${var.env}-vnet"
  resource_group_name = "aks-infra-${var.env}-rg"
}

data "azurerm_subnet" "aks-00" {
  provider             = "azurerm.aks-infra"
  name                 = "aks-00"
  virtual_network_name = "${data.azurerm_virtual_network.aks_core_vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.aks_core_vnet.resource_group_name}"
}

data "azurerm_subnet" "aks-01" {
  provider             = "azurerm.aks-infra"
  name                 = "aks-01"
  virtual_network_name = "${data.azurerm_virtual_network.aks_core_vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.aks_core_vnet.resource_group_name}"
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
  name          = "storage-account-name"
  value         = "${module.storage_account.storageaccount_name}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

resource "azurerm_key_vault_secret" "storageaccount_id" {
  name          = "storage-account-id"
  value         = "${module.storage_account.storageaccount_id}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  name          = "storage-account-primary-key"
  value         = "${module.storage_account.storageaccount_primary_access_key}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

output "storage_account_name" {
  value = "${module.storage_account.storageaccount_name}"
}

output "storage_account_primary_key" {
  sensitive = true
  value     = "${module.storage_account.storageaccount_primary_access_key}"
}