output "private_ip_address" {
    value = azurerm_network_interface.nic.private_ip_address
}
output "id" {
    value = azurerm_windows_virtual_machine.windows.id
}
output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}
output "network_interface_ipconfiguration" {
  value = azurerm_network_interface.nic.ip_configuration
}
