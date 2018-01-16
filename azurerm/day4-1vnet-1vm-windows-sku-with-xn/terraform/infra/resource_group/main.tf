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

variable "name" {}
variable "location" {}
