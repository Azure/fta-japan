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
      sampling_frequency_in_seconds = 10
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
// ------------------------------------------
// Set source to DCR
// ------------------------------------------
resource "azurerm_monitor_data_collection_rule_association" "vmjumpboxwin" {
  name                    = "vmjumpboxwin-dcra"
  target_resource_id      = module.vm_jumpbox_shared_windows.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "example"
}

resource "azurerm_monitor_data_collection_rule_association" "vmprjwin" {
  name                    = "vmjumpboxwin-dcra"
  target_resource_id      = module.vm_prj_windows.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "vmprjwin"
}

resource "azurerm_monitor_data_collection_rule_association" "vmlinuxweb" {
  name                    = "vmlinuxweb-dcra"
  target_resource_id      = module.vm_web.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  description             = "vmlinuxweb"
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

resource "azurerm_virtual_machine_extension" "vm_jumpbox_shared_windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = module.vm_jumpbox_shared_windows.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
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
