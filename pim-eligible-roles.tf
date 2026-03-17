locals {
  allowed_pim_roles = toset([
    "Storage Blob Delegator",
    "Storage Blob Data Contributor",
    "Storage Blob Data Reader",
    "Azure Storage Account Blob Tagging"
  ])

  pim_scopes = {
    rd = {
      scope = module.storage_account.storageaccount_id
      roles = local.pim_roles
    }
    rd_commondata = {
      scope = module.storage_account_rd_commondata.storageaccount_id
      roles = local.cd_pim_roles
    }
    rd_data_extract = {
      scope = module.storage_account_rd_data_extract.storageaccount_id
      roles = local.de_pim_roles
    }
    rd_location = {
      scope = module.storage_account_rd_location.storageaccount_id
      roles = local.loc_pim_roles
    }
    rd_professional = {
      scope = module.storage_account_rd_professional.storageaccount_id
      roles = local.prof_pim_roles
    }
  }

  pim_role_assignments = flatten([
    for scope_key, scope in local.pim_scopes : [
      for role_name, role in scope.roles : {
        key          = "${scope_key}:${role_name}:${role.principal_id}"
        scope        = scope.scope
        role_name    = role_name
        principal_id = role.principal_id
      } if contains(local.allowed_pim_roles, role_name)
    ]
  ])

  pim_role_assignments_by_key = {
    for assignment in local.pim_role_assignments : assignment.key => assignment
  }

  pim_role_names = toset([
    for assignment in local.pim_role_assignments : assignment.role_name
  ])
}

data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "pim_role" {
  for_each = local.pim_role_names

  name  = each.key
  scope = data.azurerm_subscription.primary.id
}

resource "time_rotating" "pim_expiry" {
  rotation_days = var.pim_expiration_days
}

resource "time_static" "pim_start" {}

resource "time_static" "pim_expiry" {
  rfc3339 = time_rotating.pim_expiry.rotation_rfc3339
}

resource "azurerm_pim_eligible_role_assignment" "storage_accounts" {
  for_each = local.pim_role_assignments_by_key

  scope              = each.value.scope
  role_definition_id = data.azurerm_role_definition.pim_role[each.value.role_name].id
  principal_id       = each.value.principal_id

  schedule {
    start_date_time = time_static.pim_start.rfc3339
    expiration {
      end_date_time = time_static.pim_expiry.rfc3339
    }
  }
}
