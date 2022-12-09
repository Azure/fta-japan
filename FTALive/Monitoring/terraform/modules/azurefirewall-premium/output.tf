output "private_ip_address" {
  value = azurerm_firewall.example.ip_configuration[0].private_ip_address
}
output "id" {
  value = azurerm_firewall.example.id
}
output "name" {
  value = azurerm_firewall.example.name
}
