//vnet
resource "azurecaf_naming_convention" "vnet" {
  for_each = var.networking

  name          = each.value.name
  resource_type = "azurerm_virtual_network"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  postfix       = lookup(each.value, "usesuffix", false) == true ? local.suffix : ""
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_virtual_network" "vnet" {
  for_each = var.networking

  name                = azurecaf_naming_convention.vnet[each.key].result
  address_space       = each.value.address_space
  resource_group_name = azurerm_resource_group.rg[each.value.resource_group_key].name
  location            = lookup(each.value, "location", local.global_settings.default_location)
  tags                = merge(lookup(each.value, "tags", {}), local.tags)
}

//Subnets
resource "azurecaf_naming_convention" "subnet" {
  for_each = var.subnets

  name          = each.value.name
  resource_type = "azurerm_subnet"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  postfix       = lookup(each.value, "usesuffix", false) == true ? local.suffix : ""
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = azurecaf_naming_convention.subnet[each.key].result
  address_prefixes     = each.value.address_prefixes
  resource_group_name  = azurerm_virtual_network.vnet[each.value.virtual_network_key].resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.virtual_network_key].name
}

//Network security group
resource "azurecaf_naming_convention" "nsg" {
  name          = "default"
  resource_type = "azurerm_network_security_group"
  convention    = local.global_settings.convention
}

resource "azurerm_network_security_group" "nsg" {
  name                = azurecaf_naming_convention.nsg.result
  location            = azurerm_resource_group.rg[var.resource_groups["core"].name].location
  resource_group_name = azurerm_resource_group.rg[var.resource_groups["core"].name].name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.allow_rdp_from
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet[var.subnets["default"].name].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}