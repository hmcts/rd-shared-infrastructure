locals {
  appinsights_name = join("-", [var.product, var.env])
}

resource "azurerm_application_insights" "appinsights" {
  name                = local.appinsights_name
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = var.appinsights_application_type
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance
      application_type,
    ]
  }
}

resource "azurerm_key_vault_secret" "applicationinsights-instrumentation-key" {
  name         = "ApplicationInsightsInstrumentationKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = module.rd_key_vault.key_vault_id
}

resource "azurerm_key_vault_secret" "app_insights_connection_string" {
  name         = "app-insights-connection-string"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = module.rd_key_vault.key_vault_id
}
