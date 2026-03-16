locals {
  pim_eligible_role_assignments = var.env != "prod" ? {} : merge(
    { for role, value in local.pim_roles : "rd-storage:${role}" => {
      scope        = module.storage_account.storageaccount_id
      role_name    = role
      principal_id = value.principal_id
    } },
    { for role, value in local.cd_pim_roles : "rd-commondata:${role}" => {
      scope        = module.storage_account_rd_commondata.storageaccount_id
      role_name    = role
      principal_id = value.principal_id
    } },
    { for role, value in local.prof_pim_roles : "rd-professional:${role}" => {
      scope        = module.storage_account_rd_professional.storageaccount_id
      role_name    = role
      principal_id = value.principal_id
    } },
    { for role, value in local.de_pim_roles : "rd-data-extract:${role}" => {
      scope        = module.storage_account_rd_data_extract.storageaccount_id
      role_name    = role
      principal_id = value.principal_id
    } },
    { for role, value in local.loc_pim_roles : "rd-location:${role}" => {
      scope        = module.storage_account_rd_location.storageaccount_id
      role_name    = role
      principal_id = value.principal_id
    } }
  )

  pim_role_names = distinct([for _, value in local.pim_eligible_role_assignments : value.role_name])
}

data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "pim_role" {
  for_each = toset(local.pim_role_names)

  name  = each.key
  scope = data.azurerm_subscription.primary.id
}

resource "azurerm_pim_eligible_role_assignment" "storage_pim" {
  for_each = local.pim_eligible_role_assignments

  scope              = each.value.scope
  role_definition_id = data.azurerm_role_definition.pim_role[each.value.role_name].id
  principal_id       = each.value.principal_id

  schedule {
    expiration {
      duration_days = var.pim_eligible_role_assignment_duration_days
    }
  }
}
