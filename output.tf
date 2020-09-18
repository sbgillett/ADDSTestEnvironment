output resource_groups {
  sensitive = false
  value     = azurerm_resource_group.rg
}

output networking {
  sensitive = false
  value     = azurerm_virtual_network.vnet
}

output pdc {
  sensitive = false
  value     = module.domain_controllers.pdc
}

output pdc_ip {
  sensitive = false
  value     = module.domain_controllers.dc1_ip
}

/*
output pdc_bootstrap_result {
  sensitive = false
  value     = module.domain_controllers.pdc_bootstrap_result
}
*/