
resource "azurerm_resource_group" "prj" {
  name     = var.rg_prj.name
  location = var.rg_prj.location
}
resource "azurerm_virtual_network" "prj" {
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.prj.name
  location            = azurerm_resource_group.prj.location
  address_space       = ["10.2.0.0/16"]
}
resource "azurerm_subnet" "prj_default" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.prj.name
  virtual_network_name = azurerm_virtual_network.prj.name
  address_prefixes     = ["10.2.0.0/24"]
}
resource "azurerm_subnet_route_table_association" "prj_default_azfw" {
  subnet_id      = azurerm_subnet.prj_default.id
  route_table_id = azurerm_route_table.hub_azfw.id
}
resource "azurerm_virtual_network_peering" "spokePrjTohub" {
  name = "SpokePrjToHub"

  resource_group_name       = azurerm_resource_group.prj.name
  virtual_network_name      = azurerm_virtual_network.prj.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "hubToSpokePrj" {
  name = "HubToSpokePrj"

  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.prj.id
  allow_forwarded_traffic   = true
}
// ------------------------------------------
// Virtual Machine
// ------------------------------------------
module "vm_prj_windows" {
  source              = "./modules/vm-windows-2019"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  name                = "vmprjwin"
  resource_group_name = azurerm_resource_group.prj.name
  location            = azurerm_resource_group.prj.location
  zone                = null
  subnet_id           = azurerm_subnet.prj_default.id
}
