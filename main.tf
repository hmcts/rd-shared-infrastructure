locals {
  common_tags = {
    "environment"  = var.env
    "Team Name"    = var.team_name
    "Team Contact" = var.team_contact
    "Destroy Me"   = var.destroy_me
  }

  tags = merge(var.common_tags, 
    map("Team Contact", "#referencedata")
  )
}