locals {
  common_tags = {
    "BuiltFrom"    = var.builtfrom
    "application"  = var.app
    "businessArea" = var.business
    "environment"  = var.env
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
    "managedBy"    = var.team_name
  }

  tags = merge(var.common_tags, {"Team Contact" = "#referencedata", "businessArea" = "CFT", "BuiltFrom" = "https://github.com/hmcts/rd-shared-infrastructure", "application" = "reference-data"})
}