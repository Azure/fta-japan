output "id" {
  value = azurerm_linux_virtual_machine.linux.id
}
output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}
output "network_interface_ipconfiguration" {
  value = azurerm_network_interface.nic.ip_configuration
}
