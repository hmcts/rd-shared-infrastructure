locals {
  alert_resource_group_name = "${var.product}-${var.env}"
}

module "rd-action-group" {
  source                 = "git@github.com:hmcts/cnp-module-action-group?ref=master"
  location               = "global"
  env                    = "${var.env}"
  resourcegroup_name     = "${local.alert_resource_group_name}"
  action_group_name      = "${var.product}-support"
  short_name             = "${var.product}-support"
  email_receiver_name    = "Ref Data Support Mailing List"
  email_receiver_address = "${data.azurerm_key_vault_secret.rd_support_email_secret.value}"
}

module "rd-profile-sync-exceptions-alert" {
  source                     = "git@github.com:hmcts/cnp-module-metric-alert?ref=master"
  location                   = "${var.appinsights_location}"
  app_insights_name          = "${var.product}-${var.env}"
  alert_name                 = "${var.product}-profile-sync-exceptions-alert"
  alert_desc                 = "All exceptions within Ref Data Profile Sync"
  app_insights_query         = "traces | where cloud_RoleName in (\"RD Profile SYNC API\") | where message startswith 'Sync Batch Job Failed::' | summarize AggregatedValue=count() by bin(timestamp, 5m), cloud_RoleName"
  custom_email_subject       = "Alert: Ref Data Profile Sync - all exceptions"
  frequency_in_minutes       = 5
  time_window_in_minutes     = 5
  severity_level             = "2"
  action_group_name          = "${var.product}-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold          = 0
  resourcegroup_name         = "${local.alert_resource_group_name}"
  enabled                    = "${var.enable_alerts}"
}