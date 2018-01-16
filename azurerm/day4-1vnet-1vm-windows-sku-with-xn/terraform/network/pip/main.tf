resource "azurerm_public_ip" "pip" {
  name                         = "${var.name}-${random_id.pip.dec}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "${var.public_ip_address_allocation}"
}

output "id" {
  value = "${azurerm_public_ip.pip.id}"
}

output "ip_address" {
  value = "${azurerm_public_ip.pip.ip_address}"
}

resource "random_id" "pip" {
  byte_length = 2
}

variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "public_ip_address_allocation" {}
