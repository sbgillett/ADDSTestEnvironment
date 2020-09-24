/*
output resource_groups {
  sensitive = false
  value     = azurerm_resource_group.rg
}

output networking {
  sensitive = false
  value     = azurerm_virtual_network.vnet
}
*/

output ip_primary_domain_controller {
  sensitive   = false
  value       = data.azurerm_public_ip.dc1.ip_address
  description = "Primary Domain Controller public IP address"
}

output ip_domain_members {
  sensitive   = false
  value       = zipmap(values(azurerm_windows_virtual_machine.vm)[*].name, values(azurerm_public_ip.vm)[*].ip_address)
  description = "Domain member's IP addresses"
}