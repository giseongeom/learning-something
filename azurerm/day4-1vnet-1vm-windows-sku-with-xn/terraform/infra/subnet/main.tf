resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.address_prefix}"
}

output "id" {
  value = "${azurerm_subnet.subnet.id}"
}

output "name" {
  value = "${azurerm_subnet.subnet.name}"
}

variable "name" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "address_prefix" {}
