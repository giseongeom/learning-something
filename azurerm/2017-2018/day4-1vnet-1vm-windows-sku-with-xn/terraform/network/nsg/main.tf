resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-${random_id.nsg.dec}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "random_id" "nsg" {
  byte_length = 4
}

output "id" {
  value = "${azurerm_network_security_group.nsg.id}"
}

output "name" {
  value = "${azurerm_network_security_group.nsg.name}"
}

variable "name" {}
variable "location" {}
variable "resource_group_name" {}
