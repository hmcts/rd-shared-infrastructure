locals {
  product                  = "rdlocation"
  rd_location_account_name = join("", [local.product, var.env])
  container_name           = "lrd-ref-data"
  container_archive_name   = "lrd-ref-data-archive"

  loc_pim_roles = var.env != "prod" ? {} : {
    "Storage Blob Data Contributor" = {
      principal_id = data.azuread_group.sc_group.id
    }
    "Storage Blob Delegator" = {
      principal_id = data.azuread_group.sc_group.id
    }
    "Storage Blob Data Reader" = {
      principal_id = data.azuread_group.sc_group.id
    }
  }
}

module "storage_account_rd_location" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=4.x"
  env                      = var.env
  storage_account_name     = local.rd_location_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = var.rd_location_storage_account_kind
  account_tier             = "Standard"
  account_replication_type = var.rd_location_storage_repl_type
  access_tier              = var.rd_location_storage_access_tier

  enable_https_traffic_only = true

  pim_roles = local.loc_pim_roles

  ip_rules = var.ip_rules

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me

  sa_subnets = local.all_valid_subnets
}

resource "azurerm_storage_container" "service_container" {
  name                 = local.container_name
  storage_account_name = module.storage_account_rd_location.storageaccount_name
}

resource "azurerm_storage_container" "service_archive_container" {
  name                 = local.container_archive_name
  storage_account_name = module.storage_account_rd_location.storageaccount_name
}

resource "azurerm_key_vault_secret" "rd_location_storage_account_name" {
  name         = "rd-location-storage-account-name"
  value        = module.storage_account_rd_location.storageaccount_name
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_location_storageaccount_id" {
  name         = "rd-location-storage-account-id"
  value        = module.storage_account_rd_location.storageaccount_id
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_location_storage_account_primary_key" {
  name         = "rd-location-storage-account-primary-key"
  value        = module.storage_account_rd_location.storageaccount_primary_access_key
  key_vault_id = module.rd_key_vault.key_vault_id
}