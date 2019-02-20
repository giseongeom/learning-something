resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.name}-${random_string.vm.result}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${var.network_interface_ids}"]
  vm_size               = "${var.vm_size}"

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.storage_image_reference_publisher}"
    offer     = "${var.storage_image_reference_offer}"
    sku       = "${var.storage_image_reference_sku}"
    version   = "${var.storage_image_reference_version}"
  }
  storage_os_disk {
    name              = "${var.osdisk_name}_${random_id.vm.dec}"
    caching           = "${var.osdisk_caching}"
    create_option     = "${var.osdisk_create_option}"
    managed_disk_type = "${var.osdisk_managed_disk_type}"
    os_type           = "${var.osdisk_os_type}"
    disk_size_gb      = "${var.osdisk_disk_size_gb}"
  }
  storage_data_disk {
    name              = "${var.datadisk_name}_${random_id.vm.dec}"
    caching           = "${var.datadisk_caching}"
    create_option     = "${var.datadisk_create_option}"
    managed_disk_type = "${var.datadisk_managed_disk_type}"
    disk_size_gb      = "${var.datadisk_disk_size_gb}"
    lun               = 0
  }
  os_profile {
    computer_name  = "${var.computer_name}-${random_string.vm.result}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "random_string" "vm" {
  length  = 4
  special = false
}

resource "random_id" "vm" {
  byte_length = 8
}

output "id" {
  value = "${azurerm_virtual_machine.vm.id}"
}

variable name {}
variable location {}
variable resource_group_name {}
variable network_interface_ids {}
variable vm_size {}

variable storage_image_reference_publisher {}
variable storage_image_reference_offer {}
variable storage_image_reference_sku {}
variable storage_image_reference_version {}

variable osdisk_name {}
variable osdisk_caching {}
variable osdisk_create_option {}
variable osdisk_managed_disk_type {}
variable osdisk_os_type {}
variable osdisk_disk_size_gb {}

variable datadisk_managed_disk_type {}
variable datadisk_disk_size_gb {}
variable datadisk_name {}
variable datadisk_create_option {}
variable datadisk_caching {}

variable computer_name {}
variable admin_username {}
variable admin_password {}
