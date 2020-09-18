/*
//Disabled for now

//Network interface
resource "azurecaf_naming_convention" "dc_nic" {
  name          = var.vm_dcn.name_prefix
  resource_type = "azurerm_network_interface"
  convention    = lookup(var.vm_dcn, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm_dcn, "max_length", null)
}

resource "azurerm_network_interface" "dc" {
  name                = "${azurecaf_naming_convention.dc_nic.result}${count.index}"
  count = var.vm_dcn.instance_count

  location            = var.vm_dcn.location
  resource_group_name = var.vm_dcn.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_dcn.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

//VM
resource "azurecaf_naming_convention" "dc" {
  name = "${var.vm_dcn.name_prefix}${count.index}"
  count = var.vm_dcn.instance_count

  resource_type = "azurerm_windows_virtual_machine_windows"
  convention    = lookup(var.vm_dcn, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm_dcn, "max_length", null)
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                = azurecaf_naming_convention.dc[count.index].result
  count = var.vm_dcn.instance_count

  resource_group_name = var.vm_dcn.resource_group_name
  location            = var.vm_dcn.location
  size                = var.vm_dcn.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.dc[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  //TODO
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
*/