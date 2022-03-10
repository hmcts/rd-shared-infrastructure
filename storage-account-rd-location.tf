locals {
  product                   = "rdlocation"
  rd_location_account_name  = join("", [local.product, var.env])
  container_name            = "lrd-ref-data"
  container_archive_name    = "lrd-ref-data-archive"

  valid_subnets = [
    data.azurerm_subnet.aks_00.id,
    data.azurerm_subnet.aks_01.id,
    data.azurerm_subnet.jenkins_subnet.id,
  ]

  cft_prod_subnets = var.env == "prod" ? [data.azurerm_subnet.prod_aks_00_subnet.id, data.azurerm_subnet.prod_aks_01_subnet.id] : []

  all_valid_subnets = concat(local.valid_subnets, local.cft_prod_subnets)
  
}

module "storage_account_rd_location" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=master"
  env                      = var.env
  storage_account_name     = local.rd_location_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.rd_location_storage_repl_type
  access_tier              = var.rd_location_storage_access_tier

  enable_https_traffic_only = true

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
  name          = "rd-location-storage-account-name"
  value         = module.storage_account_rd_location.storageaccount_name
  key_vault_id  = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_location_storageaccount_id" {
  name          = "rd-location-storage-account-id"
  value         = module.storage_account_rd_location.storageaccount_id
  key_vault_id  = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "rd_location_storage_account_primary_key" {
  name          = "rd-location-storage-account-primary-key"
  value         = module.storage_account_rd_location.storageaccount_primary_access_key
  key_vault_id  = module.rd_key_vault.key_vault_id
}