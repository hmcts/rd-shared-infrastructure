locals {
  mgmt_network_name     = "core-cftptl-intsvc-vnet"
  mgmt_network_rg_name  = "aks-infra-cftptl-intsvc-rg"
}

data "azurerm_virtual_network" "mgmt_vnet" {
  provider            = azurerm.mgmt
  name                = local.mgmt_network_name
  resource_group_name = local.mgmt_network_rg_name
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = azurerm.mgmt
  name                 = "iaas"
  virtual_network_name = data.azurerm_virtual_network.mgmt_vnet.name
  resource_group_name  = data.azurerm_virtual_network.mgmt_vnet.resource_group_name
}

data "azurerm_virtual_network" "aks_core_vnet" {
  provider            = azurerm.aks-infra
  name                = join("-", ["core", var.env, "vnet"])
  resource_group_name = join("-", ["aks-infra", var.env, "rg"])
}

data "azurerm_subnet" "aks_00" {
  provider             = azurerm.aks-infra
  name                 = "aks-00"
  virtual_network_name = data.azurerm_virtual_network.aks_core_vnet.name
  resource_group_name  = data.azurerm_virtual_network.aks_core_vnet.resource_group_name
}

data "azurerm_subnet" "aks_01" {
  provider             = azurerm.aks-infra
  name                 = "aks-01"
  virtual_network_name = data.azurerm_virtual_network.aks_core_vnet.name
  resource_group_name  = data.azurerm_virtual_network.aks_core_vnet.resource_group_name
}

data "azurerm_virtual_network" "rdo_sftp_vnet" {
  provider            = azurerm.rdo
  name                = "rdo-sftp-vnet"
  resource_group_name = "rdo-hub-sftp-prod"
}

data "azurerm_subnet" "rdo_sftp_public" {
  provider              = azurerm.rdo
  name                  = "rdo-sftp-public"
  virtual_network_name  = data.azurerm_virtual_network.rdo_sftp_vnet.name
  resource_group_name   = data.azurerm_virtual_network.rdo_sftp_vnet.resource_group_name
}

data "azurerm_subnet" "rdo_sftp_private" {
  provider              = azurerm.rdo
  name                  = "rdo-sftp-private"
  virtual_network_name  = data.azurerm_virtual_network.rdo_sftp_vnet.name
  resource_group_name   = data.azurerm_virtual_network.rdo_sftp_vnet.resource_group_name
}