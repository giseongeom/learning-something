resource "azurerm_resource_group" "resource_group" {
  name     = "${var.name}-${random_id.resource_group.dec}"
  location = "${var.location}"
}

resource "random_id" "resource_group" {
  byte_length = 4
}

output "id" {
  value = "${azurerm_resource_group.resource_group.id}"
}

output "location" {
  value = "${azurerm_resource_group.resource_group.location}"
}

output "name" {
  value = "${azurerm_resource_group.resource_group.name}"
}

variable "name" {}
variable "location" {}
