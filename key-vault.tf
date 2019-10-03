locals {
  key_vault_name = "${var.product}-${var.env}"
}

module "rd_key_vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                    = "${local.key_vault_name}"
  location                = "${var.location}"
  resource_group_name     = "${azurerm_resource_group.rg.name}"
  tenant_id               = "${var.tenant_id}"
  object_id               = "${var.jenkins_AAD_objectId}"
  product_group_object_id = "${var.rd_product_group_object_id}"
  env                     = "${var.env}"
  product                 = "${var.product}"
  common_tags             = "${local.common_tags}"

  #aks migration
  managed_identity_object_id = "${var.managed_identity_object_id}"
}

data "azurerm_key_vault" "s2s" {
  name                = "s2s-${var.env}"
  resource_group_name = "rpe-service-auth-provider-${var.env}"
}

data "azurerm_key_vault_secret" "prd-s2s" {
  name         = "microservicekey-rd-professional-api"
  key_vault_id = "${data.azurerm_key_vault.s2s.id}"
}

resource "azurerm_key_vault_secret" "prd-s2s" {
  name         = "s2s-secret"
  value        = "${data.azurerm_key_vault_secret.prd-s2s.value}"
  key_vault_id = "${module.rd_key_vault.key_vault_id}"
}

data "azurerm_key_vault_secret" "user-profile-s2s" {
  name         = "microservicekey-rd-user-profile-api"
  key_vault_id = "${data.azurerm_key_vault.s2s.id}"
}

resource "azurerm_key_vault_secret" "user-profile-s2s" {
  name         = "up-s2s-secret"
  value        = "${data.azurerm_key_vault_secret.user-profile-s2s.value}"
  key_vault_id = "${module.rd_key_vault.key_vault_id}"
}

output "vaultName" {
  value = "${local.key_vault_name}"
}
