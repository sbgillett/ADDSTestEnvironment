/*
module "domain_controllers" {
  source = "./domain_controllers"

  global_settings = local.global_settings

  //Primary DC/FSMO role holder
  vm_dc1 = {
    name               = "DC1"
    resource_group_key = "core"
    size               = "Standard_B2ms"
    //subnet_key         = "default"
    subnet_id           = azurerm_subnet.subnet["default"].id
    max_length          = 40
    location            = azurerm_resource_group.rg["core"].location
    resource_group_name = azurerm_resource_group.rg["core"].name
    private_ip_address  = var.pdc_private_ip_address
  }

  //Other member domain controllers
  vm_dcn = {
    name_prefix    = "DC"
    instance_count = 1
    //resource_group_key = "core"
    size = "Standard_B2ms"
    //subnet_key         = "default"
    max_length          = 40
    subnet_id           = azurerm_subnet.subnet["default"].id
    location            = azurerm_resource_group.rg["core"].location
    resource_group_name = azurerm_resource_group.rg["core"].name
  }

  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
  safe_mode_administrator_password = "34RumblyTumbly"
}
*/