locals {
  account_name          = join("", [var.product, var.env])
  client_service_names  = ["jud-ref-data"]
}

module "storage_account" {
  source                   = "git@github.com:hmcts/cnp-module-storage-account?ref=azurermv2"
  env                      = var.env
  storage_account_name     = local.account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  //  enable_blob_encryption    = true
  //  enable_file_encryption    = true
  enable_https_traffic_only = true

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me

  sa_subnets = [data.azurerm_subnet.aks_00.id, data.azurerm_subnet.aks_01.id, data.azurerm_subnet.jenkins_subnet.id, data.azurerm_subnet.rdo_sftp_public.id, data.azurerm_subnet.rdo_sftp_private.id]
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

output "storage_account_name" {
  value = module.storage_account.storageaccount_name
}

output "storage_account_primary_key" {
  sensitive = true
  value     = module.storage_account.storageaccount_primary_access_key
}