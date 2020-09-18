//Public IP
resource "azurecaf_naming_convention" "dc1_pip" {
  name          = var.vm_dc1.name
  resource_type = "azurerm_public_ip"
  convention    = lookup(var.vm_dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm_dc1, "max_length", null)
}

resource "azurerm_public_ip" "dc1" {
  name                = azurecaf_naming_convention.dc1_pip.result
  location            = var.vm_dc1.location
  resource_group_name = var.vm_dc1.resource_group_name
  allocation_method   = "Static"
}

//Network interface
resource "azurecaf_naming_convention" "dc1_nic" {
  name          = var.vm_dc1.name
  resource_type = "azurerm_network_interface"
  convention    = lookup(var.vm_dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm_dc1, "max_length", null)
}

resource "azurerm_network_interface" "dc1" {
  name                = azurecaf_naming_convention.dc1_nic.result
  //location            = azurerm_resource_group.rg[var.vm_dc1.resource_group_key].location
  //resource_group_name = azurerm_resource_group.rg[var.vm_dc1.resource_group_key].name
  location            = var.vm_dc1.location
  resource_group_name = var.vm_dc1.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_dc1.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address = var.vm_dc1.private_ip_address
    public_ip_address_id = azurerm_public_ip.dc1.id
  }
}

//VM
resource "azurecaf_naming_convention" "dc1" {
  name          = var.vm_dc1.name
  resource_type = "azurerm_windows_virtual_machine_windows"
  convention    = lookup(var.vm_dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm_dc1, "max_length", null)
}

resource "azurerm_windows_virtual_machine" "dc1" {
  name                = azurecaf_naming_convention.dc1.result
  resource_group_name = var.vm_dc1.resource_group_name
  location            = var.vm_dc1.location
  size                = var.vm_dc1.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.dc1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "cloud-infrastructure-services"
    offer     = "ad-dc-2019"
    sku       = "ad-dc-2019"
    version   = "0.0.5"
  }
  plan {
    name = "ad-dc-2019"
    product = "ad-dc-2019"
    publisher = "cloud-infrastructure-services"
  }
  
  //Create forest
  /*
  provisioner "file" {
    source      = "scripts/CreateADForest.ps1"
    destination = "c:/windows/temp"    
  }
  */

  lifecycle {
    ignore_changes = [
      os_disk,
      admin_username,
      admin_password
    ]
  }

  /*
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Bypass -File C:/Windows/Temp/CreateADForest.ps1 -ForestName ${var.ad_forest_name} -SafeModeAdministratorPassword ${var.safe_mode_administrator_password}"
    ]
  }

  //todo validate
  lifecycle {
    ignore_changes = [
      remote-exec
    ]
  }
  */
}

resource "azurerm_virtual_machine_extension" "dc1_bootstrap" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc1.id
  //publisher            = "Microsoft.Azure.Extensions"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"hostname | Out-File ${local.out_path}\" && exit 0"
    }
SETTINGS
}

locals {
  out_path = "C:/Windows/temp/hostname.txt"
}