// -------------------
// Managed Identity at VM must be enabled to send metrics and logs to DCR.
// -------------------
resource "azurerm_monitor_data_collection_rule" "example" {
  name                = "dcr-os"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  destinations {
    log_analytics {
      workspace_resource_id = module.la.id
      name                  = random_string.uniqstr.result
    }

    azure_monitor_metrics {
      name = "test-destination-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["test-destination-metrics"]
  }

  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-Syslog", "Microsoft-Perf"]
    destinations = [random_string.uniqstr.result]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Processor Information(_Total)\\% Privileged Time",
        "\\Processor Information(_Total)\\% User Time",
        "\\Processor Information(_Total)\\Processor Frequency",
        "\\System\\Processes",
        "\\Process(_Total)\\Thread Count",
        "\\Process(_Total)\\Handle Count",
        "\\System\\System Up Time",
        "\\System\\Context Switches/sec",
        "\\System\\Processor Queue Length",
        "\\Memory\\% Committed Bytes In Use",
        "\\Memory\\Available Bytes",
        "\\Memory\\Committed Bytes",
        "\\Memory\\Cache Bytes",
        "\\Memory\\Pool Paged Bytes",
        "\\Memory\\Pool Nonpaged Bytes",
        "\\Memory\\Pages/sec",
        "\\Memory\\Page Faults/sec",
        "\\Process(_Total)\\Working Set",
        "\\Process(_Total)\\Working Set - Private",
        "\\LogicalDisk(_Total)\\% Disk Time",
        "\\LogicalDisk(_Total)\\% Disk Read Time",
        "\\LogicalDisk(_Total)\\% Disk Write Time",
        "\\LogicalDisk(_Total)\\% Idle Time",
        "\\LogicalDisk(_Total)\\Disk Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Read Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Write Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Transfers/sec",
        "\\LogicalDisk(_Total)\\Disk Reads/sec",
        "\\LogicalDisk(_Total)\\Disk Writes/sec",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Read",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Write",
        "\\LogicalDisk(_Total)\\Avg. Disk Queue Length",
        "\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length",
        "\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(_Total)\\Free Megabytes",
        "\\Network Interface(*)\\Bytes Total/sec",
        "\\Network Interface(*)\\Bytes Sent/sec",
        "\\Network Interface(*)\\Bytes Received/sec",
        "\\Network Interface(*)\\Packets/sec",
        "\\Network Interface(*)\\Packets Sent/sec",
        "\\Network Interface(*)\\Packets Received/sec",
        "\\Network Interface(*)\\Packets Outbound Errors",
        "\\Network Interface(*)\\Packets Received Errors",
        "\\Process(msedge)\\% Processor Time",
      ]
      name = "test-datasource-perfcounter"
    }

    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
        "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=5)]]"
      ]
      name = "test-datasource-wineventlog"
    }

    syslog {
      streams = ["Microsoft-Syslog"]
      facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "mark",
        "kern",
        "local0",
        "local1",
        "local2",
        "local3",
        "local4",
        "local5",
        "local6",
        "local7",
        "lpr",
        "mail",
        "news",
        "syslog",
        "user",
        "uucp"
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
      name = "test-datasource-syslog"
    }
  }

  description = "data collection rule example"
}

// -------------------
// Deploy DCR for VM Insights by using azapi module.
// ref: https://github.com/hashicorp/terraform-provider-azurerm/issues/18481
// -------------------
resource "azapi_resource" "dcr_vminsights" {
  type      = "Microsoft.Insights/dataCollectionRules@2021-04-01"
  name      = "dcr-for-vminsights"
  parent_id = azurerm_resource_group.example.id
  location  = azurerm_resource_group.example.location

  body = jsonencode(
    {
      properties = {
        description = "Data collection rule for VM Insights."

        dataFlows = [
          {
            destinations = ["VMInsightsPerf-Logs-Dest"]
            streams      = ["Microsoft-InsightsMetrics"]
          },
          {
            destinations = ["VMInsightsPerf-Logs-Dest"]
            streams      = ["Microsoft-ServiceMap"]
          }
        ]

        dataSources = {
          extensions = [
            {
              extensionName = "DependencyAgent"
              name          = "DependencyAgentDataSource"
              streams       = ["Microsoft-ServiceMap"]
            }
          ]

          performanceCounters = [
            {
              counterSpecifiers          = ["\\VmInsights\\DetailedMetrics"]
              name                       = "VMInsightsPerfCounters"
              samplingFrequencyInSeconds = 60
              streams                    = ["Microsoft-InsightsMetrics"]
            }
          ]
        }

        destinations = {
          logAnalytics = [
            {
              name                = "VMInsightsPerf-Logs-Dest"
              workspaceResourceId = module.la.id
            }
          ]
        }
      }
    }
  )
}
data "azurerm_monitor_data_collection_rule" "vminsights" {
  name                = azapi_resource.dcr_vminsights.name
  resource_group_name = azurerm_resource_group.example.name
}

// ------------------------------------------
// Set source to DCR
// ------------------------------------------
resource "azurerm_monitor_data_collection_rule_association" "vmjumpboxwin" {
  name                    = "vmjumpboxwin-dcra"
  target_resource_id      = module.vm_jumpbox_shared_windows.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "example"
}

resource "azurerm_monitor_data_collection_rule_association" "vmjumpboxwin-vminsights" {
  name                    = "vmjumpboxwin-dcra-insights"
  target_resource_id      = module.vm_jumpbox_shared_windows.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.vminsights.id
  description             = "example"
}

resource "azurerm_monitor_data_collection_rule_association" "vmprjwin" {
  name                    = "vmjumpboxwin-dcra"
  target_resource_id      = module.vm_prj_windows.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "vmprjwin"
}
resource "azurerm_monitor_data_collection_rule_association" "vmprjwin-vminsights" {
  name                    = "vmprjwin-dcra-insights"
  target_resource_id      = module.vm_prj_windows.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.vminsights.id
  description             = "vmprjwin"
}
resource "azurerm_monitor_data_collection_rule_association" "vmlinuxweb" {
  name                    = "vmlinuxweb-dcra"
  target_resource_id      = module.vm_web.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "vmlinuxweb"
}
resource "azurerm_monitor_data_collection_rule_association" "vmlinuxweb-vminsights" {
  name                    = "vmlinuxweb-dcra-insights"
  target_resource_id      = module.vm_web.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.vminsights.id
  description             = "vmlinuxweb"
}
resource "azurerm_monitor_data_collection_rule_association" "vmcms" {
  name                    = "vmcms-dcra"
  target_resource_id      = module.vm_web_cms_windows.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "vmcms"
}
resource "azurerm_monitor_data_collection_rule_association" "vmcms-vminsights" {
  name                    = "vmcms-dcra-insights"
  target_resource_id      = module.vm_web_cms_windows.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.vminsights.id
  description             = "vmcms"
}
// ------------------------------------------
// Install extension
// ------------------------------------------
resource "azurerm_virtual_machine_extension" "vm_web" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = module.vm_web.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "vm_web_insights" {
  name                       = "DependencyAgentLinux"
  virtual_machine_id         = module.vm_web.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
  {
    "enableAMA":"true"
  }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_jumpbox_shared_windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = module.vm_jumpbox_shared_windows.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "vm_jumpbox_shared_windows_insights" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = module.vm_jumpbox_shared_windows.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
  {
    "enableAMA":"true"
  }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_prj_windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = module.vm_prj_windows.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "vm_prj_windows_insights" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = module.vm_prj_windows.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
  {
    "enableAMA":"true"
  }
SETTINGS
}
resource "azurerm_virtual_machine_extension" "vm_web_cms_windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = module.vm_web_cms_windows.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "vm_web_cms_windows_insights" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = module.vm_web_cms_windows.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
  {
    "enableAMA":"true"
  }
SETTINGS
}