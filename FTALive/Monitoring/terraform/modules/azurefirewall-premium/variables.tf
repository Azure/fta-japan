variable "rg" {
  type = object({
    name     = string
    location = string
  })
}
variable "id" {
  type    = string
  default = "dev"
}

variable "sku" {
  type    = string
  default = "Premium"
}
variable "subnet_id" {
  type = string
}

variable "zones" {
  type     = list(string)
  default  = ["1", "2", "3"]
}

variable "azurefirewall_network_rule" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                  = string
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      destination_fqdns     = list(string)
    }))
  }))
  default = [
    {
      name     = "AllowNetworkRuleCollection"
      priority = 1000
      action   = "Allow"
      rule = [
        {
          name                  = "All"
          protocols             = ["Any"]
          source_addresses      = ["*"]
          destination_addresses = ["*"]
          destination_ports     = ["*"]
          destination_fqdns     = []
        }
      ]
    }
  ]
}

variable "azurefirewall_application_rule" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name = string
      protocols = list(object({
        type = string
        port = number
      }))
      source_addresses      = list(string)
      source_ip_groups      = list(string)
      destination_addresses = list(string)
      destination_urls      = list(string)
      destination_fqdns     = list(string)
      destination_fqdn_tags = list(string)
      terminate_tls         = bool
      web_categories        = list(string)
    }))
  }))
  default = [{
    action   = "Allow"
    name     = "AllowApplicationRuleCollection"
    priority = 2000
    rule = [
      {
        name                  = "All"
        destination_addresses = []
        destination_fqdn_tags = []
        destination_fqdns     = ["*"]
        destination_urls      = []
        protocols = [
          {
            port = 80
            type = "Http"
          },
          {
            port = 443
            type = "Https"
          }
        ]
        source_addresses = ["*"]
        source_ip_groups = []
        terminate_tls    = false
        web_categories   = []
      }
    ]
  }]
}

variable "azurefirewall_nat_rule" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                = string
      protocols           = list(string)
      source_addresses    = list(string)
      destination_ports   = list(string)
      translated_address  = string
      translated_port     = string
    }))
  }))
  default = [{
    action   = "Dnat"
    name     = "TestDnatRule_SSH-SpokeVM"
    priority = 500
    rule = [{
      destination_ports   = ["22"]
      name                = "SSH"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      translated_address  = "1.1.1.1"
      translated_port     = "22"
    }]
  }]
}
