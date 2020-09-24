//Public IP
resource "azurecaf_naming_convention" "pip" {
  for_each = var.vm_domain_members

  name          = each.value.name
  resource_type = "pip"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_public_ip" "vm" {
  for_each = var.vm_domain_members

  name                = azurecaf_naming_convention.pip[each.key].result
  location            = azurerm_resource_group.rg[each.value.resource_group_key].location
  resource_group_name = azurerm_resource_group.rg[each.value.resource_group_key].name
  allocation_method   = "Static"
}


data "azurerm_public_ip" "vm" {
  for_each = var.vm_domain_members

  name                = azurerm_public_ip.vm[each.key].name
  resource_group_name = azurerm_resource_group.rg[each.value.resource_group_key].name
}


//Network interface
resource "azurecaf_naming_convention" "nic" {
  for_each = var.vm_domain_members

  name          = each.value.name
  resource_type = "nic"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_network_interface" "vm" {
  for_each   = var.vm_domain_members
  depends_on = [azurerm_network_interface.dc1] //Which has a static private IP, whereas these are dynamic

  name                = azurecaf_naming_convention.nic[each.key].result
  location            = azurerm_resource_group.rg[each.value.resource_group_key].location
  resource_group_name = azurerm_resource_group.rg[each.value.resource_group_key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[each.key].id
  }
}

//VM
resource "azurecaf_naming_convention" "vm" {
  for_each = var.vm_domain_members

  name          = each.value.name
  resource_type = "vmw"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each   = var.vm_domain_members
  depends_on = [azurerm_virtual_machine_extension.dc1_bootstrap]

  name                  = azurecaf_naming_convention.vm[each.key].result
  location              = azurerm_resource_group.rg[each.value.resource_group_key].location
  resource_group_name   = azurerm_resource_group.rg[each.value.resource_group_key].name
  size                  = each.value.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      identity, //MSI auto-applied
      os_disk,
      admin_username,
      admin_password
    ]
  }
}

//Wait for the domain to be available to join
resource "time_sleep" "wait_for_domain" {
  depends_on      = [azurerm_virtual_machine_extension.dc1_bootstrap]
  create_duration = "10m"
}

//Domain join and winrm quickconfig
resource "azurerm_virtual_machine_extension" "vm_bootstrap" {
  for_each   = var.vm_domain_members
  depends_on = [time_sleep.wait_for_domain]

  name                 = "JoinDomain"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  //Server 2008R2 ships with PS2, so we'll use netdom instead
  /*
  settings = <<-SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"${local.cmd_domain_join}\" && exit 0"
    }
  SETTINGS
  */
  //var.admin_username ends up as the first Enterprise Admin on creation of the primary DC anyway, so we'll use it here
  settings = <<-SETTINGS
    {
        "commandToExecute": "winrm quickconfig -q && netdom join %computername% /d:${var.ad_forest_name} /ud:${split(".", var.ad_forest_name)[0]}\\${var.admin_username} /pd:${var.admin_password} /reboot:2 && exit 0"
    }
  SETTINGS
  lifecycle {
    ignore_changes = all
  }
}

//todo winrm quickconfig -q on server2008r2 and under


locals {
  //Server 2008R2 ships with PS2, so we'll use netdom instead
  /*
  cmd_domain_join_code = [
    "$u = '${var.admin_username}'",
    "$p = '${var.admin_password}' | ConvertTo-SecureString -AsPlainText -Force",
    "$c = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $u,$p",
    "Add-Computer -DomainName '${var.ad_forest_name}' -Credential $c -Restart -Force"
  ]
  cmd_domain_join = join("; ", local.cmd_domain_join_code)
  */
}