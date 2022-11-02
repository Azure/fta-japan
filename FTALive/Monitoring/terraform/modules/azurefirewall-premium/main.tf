locals {
  firewall = {
    name = "fw-${var.id}"
  }
}
resource "azurerm_public_ip" "example" {
  name                = "pip-${local.firewall.name}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
}

resource "azurerm_firewall_policy" "example" {
  name                = "afwp-${var.id}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  sku                 = var.sku
}

resource "azurerm_firewall" "example" {
  name                = "afw-${var.id}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku
  zones               = var.zones
  firewall_policy_id  = azurerm_firewall_policy.example.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "RuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.example.id
  priority           = 1000

  dynamic "network_rule_collection" {
    for_each = var.azurefirewall_network_rule
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action
      dynamic "rule" {
        for_each = network_rule_collection.value.rule
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
          destination_fqdns     = rule.value.destination_fqdns
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.azurefirewall_application_rule
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action
      dynamic "rule" {
        for_each = application_rule_collection.value.rule
        content {
          name = rule.value.name
          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_urls      = rule.value.destination_urls
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags
          terminate_tls         = rule.value.terminate_tls
          web_categories        = rule.value.web_categories
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = var.azurefirewall_nat_rule
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action
      dynamic "rule" {
        for_each = nat_rule_collection.value.rule
        content {
          name                = rule.value.name
          protocols           = rule.value.protocols
          source_addresses    = rule.value.source_addresses
          destination_address = azurerm_public_ip.example.ip_address
          destination_ports   = rule.value.destination_ports
          translated_address  = rule.value.translated_address
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}
