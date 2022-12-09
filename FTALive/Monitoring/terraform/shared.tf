terraform {
  required_version = "~> 1.2.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}
provider "azurerm" {
  //use_oidc = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
}

data "http" "my_public_ip" {
  url = "https://ifconfig.me"
}

resource "azurerm_resource_group" "example" {
  name     = var.rg_shared.name
  location = var.rg_shared.location
}

resource "random_string" "uniqstr" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    resource_group_name = var.rg_shared.name
  }
}

module "la" {
  source              = "./modules/log_analytics"
  name                = "la-${random_string.uniqstr.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

// ------------------------------------------
// VNet
// ------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "hub_default" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "hub_azfw" {
  // workaround: operate subnets one after another
  // https://github.com/hashicorp/terraform-provider-azurerm/issues/3780
  depends_on = [
    azurerm_subnet.hub_default,
  ]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "hub_gw" {
  // workaround: operate subnets one after another
  // https://github.com/hashicorp/terraform-provider-azurerm/issues/3780
  depends_on = [
    azurerm_subnet.hub_default,
    azurerm_subnet.hub_azfw,
  ]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

// ------------------------------------------
// Azure Firewall
// ------------------------------------------
data "azurerm_monitor_diagnostic_categories" "azfw_diag_category" {
  resource_id = module.azfw.id
}

module "afw_diag" {
  source                     = "./modules/diagnostic_logs"
  name                       = "diag"
  target_resource_id         = module.azfw.id
  log_analytics_workspace_id = module.la.id
  diagnostic_logs            = data.azurerm_monitor_diagnostic_categories.azfw_diag_category.logs
  retention                  = 30
}
module "azfw" {
  source = "./modules/azurefirewall-premium"
  rg = {
    name     = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
  }
  id        = "shared"
  subnet_id = azurerm_subnet.hub_azfw.id

  azurefirewall_nat_rule = [
    {
      action   = "Dnat"
      name     = "DnatRuleCollection"
      priority = 500
      rule = [
        {
          name               = "RDP"
          source_addresses   = [data.http.my_public_ip.body]
          destination_ports  = ["33389"]
          protocols          = ["TCP"]
          translated_address = module.vm_jumpbox_shared_windows.network_interface_ipconfiguration[0].private_ip_address
          translated_port    = "3389"
        }
      ]
    }
  ]
}

resource "azurerm_route_table" "hub_azfw" {
  name                          = "rt-shared-azfw"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  disable_bgp_route_propagation = false

  route = [{
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.azfw.private_ip_address
    }
  ]
}
resource "azurerm_subnet_route_table_association" "shared_default_azfw" {
  subnet_id      = azurerm_subnet.hub_default.id
  route_table_id = azurerm_route_table.hub_azfw.id
}

// ------------------------------------------
// Virtual Machine
// ------------------------------------------
module "vm_jumpbox_shared_windows" {
  source              = "./modules/vm-windows-2019"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  name                = "vmjumpboxwin"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  zone                = null
  subnet_id           = azurerm_subnet.hub_default.id
}

