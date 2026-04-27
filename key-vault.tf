locals {
  key_vault_name = join("-", [var.product, var.env])
}

module "rd_key_vault" {
  source                               = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                                 = local.key_vault_name
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.rg.name
  tenant_id                            = var.tenant_id
  object_id                            = var.jenkins_AAD_objectId
  jenkins_object_id                    = data.azurerm_user_assigned_identity.jenkins.principal_id
  product_group_object_id              = var.rd_product_group_object_id
  env                                  = var.env
  product                              = var.product
  common_tags                          = local.tags
  create_managed_identity              = true
  additional_managed_identities_access = var.additional_managed_identities_access
}

data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}
