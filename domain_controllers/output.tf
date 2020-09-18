output pdc {
  sensitive = false
  value     = azurerm_windows_virtual_machine.dc1
}

output dc1_ip {
  sensitive = false
  value     = azurerm_public_ip.dc1
}

/*
output pdc_bootstrap_result {
  value = azurerm_virtual_machine_extension.dc1_bootstrap.result
}
*/