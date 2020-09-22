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

output pdc_ip {
  sensitive   = false
  value       = data.azurerm_public_ip.dc1.ip_address
  description = "Primary Domain Controller public IP address"
}


/*
output pdc_bootstrap_result {
  sensitive = false
  value     = module.domain_controllers.pdc_bootstrap_result
}
*/