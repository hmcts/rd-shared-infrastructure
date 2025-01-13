locals {
  tags = merge(var.common_tags, tomap({
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
    "managedBy"    = var.team_name
    "application"  = "reference-data"
    "builtFrom"    = "https://github.com/hmcts/rd-shared-infrastructure"
    "businessArea" = "CFT"
  }))
}
