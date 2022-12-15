locals {
  common_tags = {
    "BuiltFrom"    = "https://github.com/hmcts/rd-shared-infrastructure"
    "application"  = "reference-data"
    "businessArea" = "CFT"
    "environment"  = var.env
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
    "managedBy"    = var.team_name
  }

  tags = merge(var.common_tags, {"Team Contact" = "#referencedata"})
}