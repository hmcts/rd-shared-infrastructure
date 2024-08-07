locals {
  account_name         = join("", [var.product, var.env])
  client_service_names = ["jud-ref-data"]

  valid_subnets = [
    data.azurerm_subnet.aks_00.id,
    data.azurerm_subnet.aks_01.id,
    data.azurerm_subnet.jenkins_subnet.id,
    data.azurerm_subnet.bau_bais_private_prod.id
  ]

  cft_prod_subnets = var.env == "prod" ? [data.azurerm_subnet.prod_aks_00_subnet.id, data.azurerm_subnet.prod_aks_01_subnet.id] : []

  all_valid_subnets = concat(local.valid_subnets, local.cft_prod_subnets)

  pim_roles = var.env != "prod" ? {} : {
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

  pim_roles = local.pim_roles

  ip_rules = var.ip_rules

  // Tags
  common_tags  = local.tags
  team_contact = var.team_contact
  destroy_me   = var.destroy_me

  sa_subnets = local.all_valid_subnets
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
  name         = "storage-account-name"
  value        = module.storage_account.storageaccount_name
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "storageaccount_id" {
  name         = "storage-account-id"
  value        = module.storage_account.storageaccount_id
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  name         = "storage-account-primary-key"
  value        = module.storage_account.storageaccount_primary_access_key
  key_vault_id = module.rd_key_vault.key_vault_id
}

locals {
  storage_to_import = {
    "Storage Blob Delegator"        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Reader"      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Contributor" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
  }
  storage_rd_commondata_to_import = {
    "Storage Blob Delegator"        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdcommondataprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Reader"      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdcommondataprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Contributor" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdcommondataprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
  }
  storage_rd_data_extract_to_import = {
    "Storage Blob Data Reader"      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rddataextractprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Contributor" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rddataextractprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Delegator"        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rddataextractprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
  }
  storage_rd_location_to_import = {
    "Storage Blob Data Reader"      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdlocationprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Contributor" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdlocationprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Delegator"        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdlocationprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
  }
  storage_rd_professional_to_import = {
    "Storage Blob Data Reader"      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprofessionalprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Data Contributor" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprofessionalprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
    "Storage Blob Delegator"        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rd-prod/providers/Microsoft.Storage/storageAccounts/rdprofessionalprod|/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a|f0a367e1-7e08-42b5-81e4-c848787e6f1e"
  }
}

data "azurerm_subscription" "current" {}

import {
  for_each = var.env == "prod" ? { "import" = "import" } : {}
  to       = module.storage_account.time_static.pim_start
  id       = "2024-03-13T15:05:53.387Z"
}

import {
  depends_on = module.storage_account.time_static.pim_start
  for_each = var.env == "prod" ? local.storage_to_import : {}
  to       = module.storage_account.azurerm_pim_eligible_role_assignment.this[each.key]
  id       = each.value
}


import {
  for_each = var.env == "prod" ? { "import" = "import" } : {}
  to       = module.storage_account_rd_commondata.time_static.pim_start
  id       = "2024-03-13T15:05:54.513Z"
}

import {
  for_each = var.env == "prod" ? local.storage_rd_commondata_to_import : {}
  to       = module.storage_account_rd_commondata.azurerm_pim_eligible_role_assignment.this[each.key]
  id       = each.value
}

import {
  for_each = var.env == "prod" ? { "import" = "import" } : {}
  to       = module.storage_account_rd_data_extract.time_static.pim_start
  id       = "2024-03-13T15:05:53.377Z"
}

import {
  for_each = var.env == "prod" ? local.storage_rd_data_extract_to_import : {}
  to       = module.storage_account_rd_data_extract.azurerm_pim_eligible_role_assignment.this[each.key]
  id       = each.value
}

import {
  for_each = var.env == "prod" ? { "import" = "import" } : {}
  to       = module.storage_account_rd_location.time_static.pim_start
  id       = "2024-03-13T15:06:04.29Z"
}

import {
  for_each = var.env == "prod" ? local.storage_rd_location_to_import : {}
  to       = module.storage_account_rd_location.azurerm_pim_eligible_role_assignment.this[each.key]
  id       = each.value
}

import {
  for_each = var.env == "prod" ? { "import" = "import" } : {}
  to       = module.storage_account_rd_professional.time_static.pim_start
  id       = "2024-03-13T15:06:03.553Z"
}

import {
  for_each = var.env == "prod" ? local.storage_rd_professional_to_import : {}
  to       = module.storage_account_rd_professional.azurerm_pim_eligible_role_assignment.this[each.key]
  id       = each.value
}
