locals {
  account_name          = join("", [var.product, var.env])
  client_service_names  = ["jud-ref-data"]

  valid_subnets = [
    data.azurerm_subnet.aks_00.id,
    data.azurerm_subnet.aks_01.id,
    data.azurerm_subnet.jenkins_subnet.id,
    data.azurerm_subnet.rdo_sftp_public.id,
    data.azurerm_subnet.rdo_sftp_private.id,
    data.azurerm_subnet.bau_bais_private_prod.id
  ]

  cft_prod_subnets = var.env == "prod" ? [data.azurerm_subnet.prod_aks_00_subnet.id, data.azurerm_subnet.prod_aks_01_subnet.id] : []

  all_valid_subnets = concat(local.valid_subnets, local.cft_prod_subnets)
}

module "storage_account" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=master"
  env                      = var.env
  storage_account_name     = local.account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = var.rd_storage_account_kind
  account_tier             = "Standard"
  account_replication_type = var.rd_storage_repl_type
  access_tier              = var.rd_storage_access_tier

  //  enable_blob_encryption    = true
  //  enable_file_encryption    = true
  enable_https_traffic_only = true

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me

  sa_subnets = local.all_valid_subnets

  network_rules {
    ip_rules                   = var.ip_rules
  }
}

resource "azurerm_storage_container" "service_containers" {
  name                 = local.client_service_names[count.index]
  storage_account_name = module.storage_account.storageaccount_name
  count                = length(local.client_service_names)
}

resource "azurerm_storage_container" "service_rejected_containers" {
  name                 = join("-", [local.client_service_names[count.index], "archive"])
  storage_account_name = module.storage_account.storageaccount_name
  count                = length(local.client_service_names)
}

resource "azurerm_storage_container" "kt_files_container" {
  name                 = "kt-files"
  count                = lower(var.env) == "aat" ? 1 : 0
  storage_account_name = module.storage_account.storageaccount_name
}

resource "azurerm_key_vault_secret" "storage_account_name" {
  name          = "storage-account-name"
  value         = module.storage_account.storageaccount_name
  key_vault_id  = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "storageaccount_id" {
  name          = "storage-account-id"
  value         = module.storage_account.storageaccount_id
  key_vault_id  = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  name          = "storage-account-primary-key"
  value         = module.storage_account.storageaccount_primary_access_key
  key_vault_id  = module.rd_key_vault.key_vault_id
}
