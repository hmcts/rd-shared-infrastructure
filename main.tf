module "ctags" {
      BuiltFrom    = var.built_from
      application  = var.app
      businessArea = var.business_area
      environment  = var.env
      Team Name    = var.team_name
      Team Contact = var.team_contact
      Destroy Me   = var.destroy_me
      managedBy    = var.team_name
}

locals {
  common_tags = module.ctags.common_tags

  tags = merge(var.common_tags, {Team Contact = "#referencedata"})
}