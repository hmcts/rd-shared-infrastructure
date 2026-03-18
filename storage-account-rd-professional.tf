locals {
  prd_product                = "rdprofessional"
  rd_prd_account_name        = join("", [local.prd_product, var.env])
  prd_container_name         = "rd-prd-data"
  prd_container_archive_name = "rd-prd-data-archive"

  prof_pim_roles = var.env != "prod" ? {} : {
    "Storage Blob Data Contributor" = {
      principal_id = data.azuread_group.sc_group.id
      duration_days = 365
    }
    "Storage Blob Delegator" = {
      principal_id = data.azuread_group.sc_group.id
      duration_days = 365
    }
    "Storage Blob Data Reader" = {
      principal_id = data.azuread_group.sc_group.id
      duration_days = 365
    }
  }
}

module "storage_account_rd_professional" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=30795"
  env                      = var.env
  storage_account_name     = local.rd_prd_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = var.rd_professional_storage_account_kind
  account_tier             = "Standard"
  account_replication_type = var.rd_professional_storage_repl_type
  access_tier              = var.rd_professional_storage_access_tier

  enable_https_traffic_only = true

  pim_roles = local.prof_pim_roles

  ip_rules = var.ip_rules

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me

  sa_subnets = local.all_valid_subnets
}

resource "azurerm_storage_container" "professional_data_service_container" {
  name                 = local.prd_container_name
  storage_account_name = module.storage_account_rd_professional.storageaccount_name
}

resource "azurerm_key_vault_secret" "rd_prd_storage_account_name" {
  name         = "rd-prd-storage-account-name"
  value        = module.storage_account_rd_professional.storageaccount_name
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_prd_storageaccount_id" {
  name         = "rd-prd-storage-account-id"
  value        = module.storage_account_rd_professional.storageaccount_id
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_prd_storage_account_primary_key" {
  name         = "rd-prd-storage-account-primary-key"
  value        = module.storage_account_rd_professional.storageaccount_primary_access_key
  key_vault_id = module.rd_key_vault.key_vault_id
}
