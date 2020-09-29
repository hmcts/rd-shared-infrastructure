locals {
  product                   = "ldlocation"
  ld_location_account_name  = "${local.product}${var.env}"
  container_name            = "lrd-ref-data"
  container_archive_name    = "lrd-ref-data-archive"
}

module "storage_account_ld_location" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=master"
  env                      = "${var.env}"
  storage_account_name     = "${local.ld_location_account_name}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "${var.ld_location_storage_repl_type}"
  access_tier              = "${var.ld_location_storage_access_tier}"

  enable_https_traffic_only = true

  // Tags
  common_tags  = "${local.tags}"
  team_contact = "${var.team_contact}"
  destroy_me   = "${var.destroy_me}"

  sa_subnets = ["${data.azurerm_subnet.aks-01.id}", "${data.azurerm_subnet.aks-00.id}", "${data.azurerm_subnet.jenkins_subnet.id}"]
}

resource "azurerm_storage_container" "service_container" {
  name                 = "${local.container_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${module.storage_account_ld_location.storageaccount_name}"
}

resource "azurerm_storage_container" "service_archive_container" {
  name                 = "${local.container_archive_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${module.storage_account_ld_location.storageaccount_name}"
}

resource "azurerm_key_vault_secret" "ld_location_storage_account_name" {
  name          = "ld-location-storage-account-name"
  value         = "${module.storage_account_ld_location.storageaccount_name}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

resource "azurerm_key_vault_secret" "ld_location_storageaccount_id" {
  name          = "ld-location-storage-account-id"
  value         = "${module.storage_account_ld_location.storageaccount_id}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

resource "azurerm_key_vault_secret" "ld_location_storage_account_primary_key" {
  name          = "ld-location-storage-account-primary-key"
  value         = "${module.storage_account_ld_location.storageaccount_primary_access_key}"
  key_vault_id  = "${data.azurerm_key_vault.key_vault.id}"
}

output "ld_location_storage_account_name" {
  value = "${module.storage_account_ld_location.storageaccount_name}"
}

output "ld_location_storage_account_primary_key" {
  sensitive = true
  value     = "${module.storage_account_ld_location.storageaccount_primary_access_key}"
}