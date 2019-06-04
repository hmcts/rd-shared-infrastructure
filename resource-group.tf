
resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = "${var.location}"
  tags     = "${local.tags}"
}

output "resourceGroup" {
  value = "${azurerm_resource_group.rg.name}"
}
