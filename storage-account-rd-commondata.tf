locals {
  cd_product                = "rdcommondata"
  rd_cd_account_name        = join("", [local.cd_product, var.env])
  cd_container_name         = "rd-common-data"
  cd_container_archive_name = "rd-common-data-archive"
}

module "storage_account_rd_commondata" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=master"
  env                      = var.env
  storage_account_name     = local.rd_cd_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = var.rd_commondata_storage_account_kind
  account_tier             = "Standard"
  account_replication_type = var.rd_commondata_storage_repl_type
  access_tier              = var.rd_commondata_storage_access_tier

  enable_https_traffic_only = true

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me
  business_area= var.business_area
  app          = var.app
  built_from    = var.built_from
  sa_subnets = local.all_valid_subnets
}

resource "azurerm_storage_container" "common_data_service_container" {
  name                 = local.cd_container_name
  storage_account_name = module.storage_account_rd_commondata.storageaccount_name
}

resource "azurerm_storage_container" "common_data_service_archive_container" {
  name                 = local.cd_container_archive_name
  storage_account_name = module.storage_account_rd_commondata.storageaccount_name
}

resource "azurerm_key_vault_secret" "rd_cd_storage_account_name" {
  name         = "rd-commondata-storage-account-name"
  value        = module.storage_account_rd_commondata.storageaccount_name
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_cd_storageaccount_id" {
  name         = "rd-commondata-storage-account-id"
  value        = module.storage_account_rd_commondata.storageaccount_id
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_cd_storage_account_primary_key" {
  name         = "rd-commondata-storage-account-primary-key"
  value        = module.storage_account_rd_commondata.storageaccount_primary_access_key
  key_vault_id = module.rd_key_vault.key_vault_id
}
