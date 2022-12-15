locals {
  common_tags = {
    "environment"  = var.env
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
    "managedBy"    = var.team_name
    "BuiltFrom"    = "https://github.com/hmcts/rd-shared-infrastructure"
  }

  tags = merge(var.common_tags, {"Team Contact" = "#referencedata"})
}