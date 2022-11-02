
resource "azurerm_resource_group" "web" {
  name     = var.rg_web.name
  location = var.rg_web.location
}
resource "azurerm_virtual_network" "web" {
  name                = "vnet-web"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  address_space       = ["10.1.0.0/16"]
}
resource "azurerm_subnet" "web_default" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.web.name
  address_prefixes     = ["10.1.0.0/24"]
}
resource "azurerm_subnet" "web_appgw" {
  name                                      = "snet-appgw"
  resource_group_name                       = azurerm_resource_group.web.name
  virtual_network_name                      = azurerm_virtual_network.web.name
  address_prefixes                          = ["10.1.1.0/24"]
}
resource "azurerm_subnet_route_table_association" "web_default_azfw" {
  subnet_id      = azurerm_subnet.web_default.id
  route_table_id = azurerm_route_table.hub_azfw.id
}
resource "azurerm_virtual_network_peering" "spokeWebTohub" {
  name = "SpokeWebToHub"

  resource_group_name       = azurerm_resource_group.web.name
  virtual_network_name      = azurerm_virtual_network.web.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "hubToSpokeWeb" {
  name = "HubToSpokeWeb"

  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.web.id
  allow_forwarded_traffic   = true
}
// ------------------------------------------
// Virtual Machine
// ------------------------------------------
module "vm_web" {
  source              = "./modules/vm-linux"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  name                = "vmlinuxweb"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  subnet_id           = azurerm_subnet.web_default.id
  custom_data         = <<EOF
#cloud-config
packages_update: true
packages_upgrade: true
runcmd:
  - apt install -y nginx
EOF
}

# --------------------------
# Application Gateway
# --------------------------

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name_vm   = "beap-vm"
  frontend_port_name             = "feport"
  frontend_ip_configuration_name = "feip"
  listener_name                  = "httplstn"
  request_routing_rule_name      = "rqrt"
  http_setting_name              = "httpsetting"
}

resource "azurerm_application_gateway" "web" {
  name                = "appgw-web"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.web_appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  // -----------------------
  // BackendPool
  // -----------------------
  // VM
  backend_address_pool {
    name  = local.backend_address_pool_name_vm
    fqdns = [module.vm_web.network_interface_ipconfiguration.0.private_ip_address]
  }

  // -----------------------
  // HTTP Settings
  // -----------------------
  // path: /
  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    path                                = ""
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
  }

  // -----------------------
  // Listener
  // -----------------------
  // from: public
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  // -----------------------
  // Routing Rule
  // -----------------------
  // for: public

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    priority                   = "1000"
    backend_address_pool_name  = local.backend_address_pool_name_vm
    backend_http_settings_name = local.http_setting_name
  }
  /*
  url_path_map {
    name = "my-url-path-map"
    // path: /
    default_backend_address_pool_name  = local.backend_address_pool_name_vm
    default_backend_http_settings_name = local.http_setting_name
    // path: /staging
    path_rule {
      name                       = "my-path-rule"
      paths                      = ["/staging/*"]
      backend_address_pool_name  = local.backend_address_pool_name_vm
      backend_http_settings_name = local.http_setting_name
    }
  }
*/
}
