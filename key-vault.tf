locals {
  key_vault_name = join("-", [var.product, var.env])
}

module "rd_key_vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=azurermv2"
  name                    = local.key_vault_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  tenant_id               = var.tenant_id
  object_id               = var.jenkins_AAD_objectId
  product_group_object_id = var.rd_product_group_object_id
  env                     = var.env
  product                 = var.product
  common_tags             = local.common_tags

  #aks migration
  managed_identity_object_ids = [var.managed_identity_object_id]
  create_managed_identity     = true
}

output "vaultName" {
  value = module.rd_key_vault.key_vault_name
}