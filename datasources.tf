locals {
  mgmt_network_name    = "cft-ptl-vnet"
  mgmt_network_rg_name = "cft-ptl-network-rg"

  prod_vnet_name           = "cft-prod-vnet"
  prod_vnet_resource_group = "cft-prod-network-rg"

  aks_core_vnet    = "cft-${var.env}-vnet"
  aks_core_vnet_rg = "cft-${var.env}-network-rg"
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
  name                = local.aks_core_vnet
  resource_group_name = local.aks_core_vnet_rg
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

data "azurerm_virtual_network" "bau_bais_prod_vnet" {
  provider            = azurerm.sds_prod
  name                = "bau-bais_prod_network"
  resource_group_name = "bau-bais_prod_network_rg"
}

data "azurerm_subnet" "bau_bais_private_prod" {
  provider             = azurerm.sds_prod
  name                 = "bau-bais_private_prod"
  virtual_network_name = data.azurerm_virtual_network.bau_bais_prod_vnet.name
  resource_group_name  = data.azurerm_virtual_network.bau_bais_prod_vnet.resource_group_name
}
