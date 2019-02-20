provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

terraform {
  required_version = ">= 0.11.2"
}

module "resource_group" {
  source = "./infra/resource_group"

  name     = "${var.azure_resource_group_name_prefix}"
  location = "${var.azure_resource_group_location}"
}

module "vnet" {
  source = "./infra/vnet"

  name                = "labvNet"
  location            = "${module.resource_group.location}"
  resource_group_name = "${module.resource_group.name}"
  address_space       = "172.16.0.0/20"
}

module "subnet0" {
  source = "./infra/subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = "${module.resource_group.name}"
  virtual_network_name = "${module.vnet.name}"
  address_prefix       = "172.16.0.0/24"
}

module "subnet1" {
  source = "./infra/subnet"

  name                 = "subnet-1-default"
  resource_group_name  = "${module.resource_group.name}"
  virtual_network_name = "${module.vnet.name}"
  address_prefix       = "172.16.1.0/24"
}

module "subnet2" {
  source = "./infra/subnet"

  name                 = "subnet-2"
  resource_group_name  = "${module.resource_group.name}"
  virtual_network_name = "${module.vnet.name}"
  address_prefix       = "172.16.2.0/24"
}

module "pip1" {
  source = "./network/pip"

  name                         = "pip-${var.vmName}"
  location                     = "${module.resource_group.location}"
  resource_group_name          = "${module.resource_group.name}"
  public_ip_address_allocation = "static"
}

module "nic1" {
  source = "./network/nic"

  name                          = "nic-${var.vmName}"
  location                      = "${module.resource_group.location}"
  resource_group_name           = "${module.resource_group.name}"
  enable_accelerated_networking = "true"
  ip_configuration_name         = "ipconfig1"
  subnet_id                     = "${module.subnet1.id}"
  public_ip_address_id          = "${module.pip1.id}"
  network_security_group_id     = "${module.nsg1.id}"
}

module "nsg1" {
  source = "./network/nsg"

  name                = "nsg-${var.vmName}"
  location            = "${module.resource_group.location}"
  resource_group_name = "${module.resource_group.name}"
}

module "nsg1rule" {
  source = "./network/nsg-rule"

  allowed_ip_list             = "${join(",", var.office_ip_list)},${join(",", var.home_ip_list)}"
  name                        = "Allow-3389"
  description                 = "Locks inbound down to rdp default port 3389"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "3389"
  destination_address_prefix  = "*"
  resource_group_name         = "${module.resource_group.name}"
  network_security_group_name = "${module.nsg1.name}"

  # See https://github.com/terraform-providers/terraform-provider-azurerm/pull/692
}

module "vm" {
  source = "./compute/vm"

  name                  = "${var.vmName}"
  location              = "${module.resource_group.location}"
  resource_group_name   = "${module.resource_group.name}"
  network_interface_ids = "${module.nic1.id}"
  vm_size               = "${var.vmSize}"

  storage_image_reference_publisher = "MicrosoftWindowsServer"
  storage_image_reference_offer     = "WindowsServer"
  storage_image_reference_sku       = "2016-Datacenter"
  storage_image_reference_version   = "latest"

  osdisk_name              = "${var.vmName}_osdisk"
  osdisk_caching           = "ReadWrite"
  osdisk_create_option     = "FromImage"
  osdisk_managed_disk_type = "Premium_LRS"
  osdisk_os_type           = "Windows"
  osdisk_disk_size_gb      = "256"

  datadisk_name              = "${var.vmName}_datadisk"
  datadisk_caching           = "ReadOnly"
  datadisk_create_option     = "Empty"
  datadisk_managed_disk_type = "Premium_LRS"
  datadisk_disk_size_gb      = "256"

  computer_name  = "${var.vmName}"
  admin_username = "${var.adminUsername}"
  admin_password = "${var.adminPassword}"
}

output "resource_group_id" {
  value = "${module.resource_group.id}"
}

output "resource_group_location" {
  value = "${module.resource_group.location}"
}

output "resource_group_name" {
  value = "${module.resource_group.name}"
}

output "network_security_group_id" {
  value = "${module.nsg1.id}"
}

output "network_security_group_name" {
  value = "${module.nsg1.name}"
}

variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "azure_resource_group_location" {
  default = "westus"
}

variable "azure_resource_group_name_prefix" {
  default = "lab-westus"
}

variable "vmName" {
  default = "lab"
}

variable "vmSize" {
  default = "Standard_DS4_v2"
}

variable "adminUsername" {
  default = "vagrant"
}

variable "adminPassword" {}

variable "home_ip_list" {
  type = "list"

  default = [
    "1.228.0.0/16",
    "1.229.0.0/16",
  ]
}

variable "office_ip_list" {
  type = "list"

  default = [
    "210.216.0.0/16",
    "210.217.0.0/16",
  ]
}
