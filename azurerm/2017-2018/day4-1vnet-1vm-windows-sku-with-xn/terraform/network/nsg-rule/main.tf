resource "azurerm_network_security_rule" "nsg_rule" {
  count                       = "${length(split(",", var.allowed_ip_list))}"
  name                        = "${var.name}-${var.direction}-${count.index}"
  description                 = "${var.description} from ${element(split(",", var.allowed_ip_list), count.index)}"
  priority                    = "${var.priority + count.index}"
  direction                   = "${var.direction}"
  access                      = "${var.access}"
  protocol                    = "${var.protocol}"
  source_port_range           = "${var.source_port_range}"
  destination_port_range      = "${var.destination_port_range}"
  source_address_prefix       = "${element(split(",", var.allowed_ip_list), count.index)}"
  destination_address_prefix  = "${var.destination_address_prefix}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${var.network_security_group_name}"
}

variable "allowed_ip_list" {}
variable "name" {}
variable "description" {}
variable "priority" {}
variable "direction" {}
variable "access" {}
variable "protocol" {}
variable "source_port_range" {}
variable "source_address_prefix" {}
variable "destination_port_range" {}
variable "destination_address_prefix" {}
variable "resource_group_name" {}
variable "network_security_group_name" {}
