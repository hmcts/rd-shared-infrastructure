locals {
  common_tags = {
    "BuiltFrom"    = var.built_from
    "application"  = var.app
    "businessArea" = var.business_area
    "environment"  = var.env
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
    "managedBy"    = var.team_name
  }

  tags = merge(var.common_tags, {"Team Contact" = "#referencedata",  "BuiltFrom" = "https://github.com/hmcts/rd-shared-infrastructure"})
}