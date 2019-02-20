resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-${random_id.vnet.dec}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.address_space}"]
  location            = "${var.location}"
}

resource "random_id" "vnet" {
  byte_length = 4
}

output "id" {
  value = "${azurerm_virtual_network.vnet.id}"
}

output "location" {
  value = "${azurerm_virtual_network.vnet.location}"
}

output "name" {
  value = "${azurerm_virtual_network.vnet.name}"
}

output "address_space" {
  value = "${azurerm_virtual_network.vnet.address_space}"
}

variable "name" {}
variable "resource_group_name" {}
variable "address_space" {}
variable "location" {}
