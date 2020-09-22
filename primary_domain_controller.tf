//Public IP
resource "azurecaf_naming_convention" "dc1_pip" {
  name          = var.vm.dc1.name
  resource_type = "azurerm_public_ip"
  convention    = lookup(var.vm.dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm.dc1, "max_length", null)
}

resource "azurerm_public_ip" "dc1" {
  name                = azurecaf_naming_convention.dc1_pip.result
  location            = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].location
  resource_group_name = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].name
  allocation_method   = "Static"
}

data "azurerm_public_ip" "dc1" {
  name                = azurerm_public_ip.dc1.name
  resource_group_name = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].name
}

//Network interface
resource "azurecaf_naming_convention" "dc1_nic" {
  name          = var.vm.dc1.name
  resource_type = "azurerm_network_interface"
  convention    = lookup(var.vm.dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm.dc1, "max_length", null)
}

resource "azurerm_network_interface" "dc1" {
  name                = azurecaf_naming_convention.dc1_nic.result
  location            = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].location
  resource_group_name = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[var.vm.dc1.subnet_key].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm.dc1.private_ip_address
    public_ip_address_id          = azurerm_public_ip.dc1.id
  }
}

//VM
resource "azurecaf_naming_convention" "dc1" {
  name          = var.vm.dc1.name
  resource_type = "azurerm_windows_virtual_machine_windows"
  convention    = lookup(var.vm.dc1, "convention", local.global_settings.convention)
  max_length    = lookup(var.vm.dc1, "max_length", null)
}

resource "azurerm_windows_virtual_machine" "dc1" {
  name                  = azurecaf_naming_convention.dc1.result
  location              = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].location
  resource_group_name   = azurerm_resource_group.rg[var.vm.dc1.resource_group_key].name
  size                  = var.vm.dc1.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
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
    name      = "ad-dc-2019"
    product   = "ad-dc-2019"
    publisher = "cloud-infrastructure-services"
  }

  lifecycle {
    ignore_changes = [
      os_disk,
      admin_username,
      admin_password
    ]
  }
}

resource "azurerm_virtual_machine_extension" "dc1_bootstrap" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ${local.dc1_bootstrap_pscmd} && exit 0",
        "fileUris": ["https://raw.githubusercontent.com/sbgillett/ADDSTestEnvironment/master/scripts/CreateADForest.ps1"]
    }
SETTINGS
}

locals {
  dc1_bootstrap_pscmd = "./CreateADForest.ps1 -ForestName ${var.ad_forest_name} -SafeModeAdministratorPassword ${var.safe_mode_administrator_password}"

  //You can also embed the script directly like this
  /*
  dc1_bootstrap_pscmd_1 = "$SMP = '${var.safe_mode_administrator_password}' | ConvertTo-SecureString -AsPlainText -Force"
  dc1_bootstrap_pscmd_2 = "Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath C:/Windows/NTDS -DomainName ${var.ad_forest_name} -InstallDns:$true -LogPath C:/Windows/NTDS -NoRebootOnCompletion:$false -SysvolPath C:/Windows/SYSVOL -SafeModeAdministratorPassword $SMP -Force"
  dc1_bootstrap_pscmd = "${local.dc1_bootstrap_pscmd_1}; ${local.dc1_bootstrap_pscmd_2}"
  */
}