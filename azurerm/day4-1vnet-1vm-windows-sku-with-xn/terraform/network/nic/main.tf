resource "azurerm_network_interface" "nic" {
  name                          = "${var.name}-${random_id.nic.dec}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  network_security_group_id     = "${var.network_security_group_id}"
  enable_accelerated_networking = "${var.enable_accelerated_networking}"

  ip_configuration {
    name                          = "${var.ip_configuration_name}-${random_id.nic.dec}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${var.public_ip_address_id}"
  }
}

output "id" {
  value = "${azurerm_network_interface.nic.id}"
}

output "private_ip_address" {
  value = "${azurerm_network_interface.nic.private_ip_address}"
}

resource "random_id" "nic" {
  byte_length = 2
}

variable name {}
variable location {}
variable resource_group_name {}
variable enable_accelerated_networking {}
variable ip_configuration_name {}
variable subnet_id {}
variable public_ip_address_id {}
variable network_security_group_id {}
